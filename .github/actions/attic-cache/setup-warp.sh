#!/usr/bin/env bash
set -euo pipefail

# This action owns WARP only on disposable GitHub-hosted runners.
if [[ "${RUNNER_ENVIRONMENT:-}" != github-hosted ]]; then
  echo '::error::WARP setup requires a disposable GitHub-hosted runner.'
  exit 1
fi

umask 077
state="$RUNNER_TEMP/attic-ci"
case "$RUNNER_OS" in
  Linux) mdm_dir=/var/lib/cloudflare-warp ;;
  macOS) mdm_dir='/Library/Application Support/Cloudflare' ;;
  *) echo "::error::Unsupported runner OS: $RUNNER_OS"; exit 1 ;;
esac
if sudo test -e "$mdm_dir/mdm.xml"; then
  echo '::error::An existing WARP MDM configuration is present; refusing to overwrite it.'
  exit 1
fi

# Track ownership before installing credentials so cleanup also handles partial failures.
touch "$state/warp-managed"
python3 - "$state/mdm.xml" <<'PY'
import os
import sys
from pathlib import Path
from xml.sax.saxutils import escape

values = {
    "organization": os.environ["CF_TEAM_NAME"],
    "auth_client_id": os.environ["CF_ACCESS_CLIENT_ID"],
    "auth_client_secret": os.environ["CF_ACCESS_CLIENT_SECRET"],
    "service_mode": "warp",
}
entries = [f"<key>{key}</key><string>{escape(value)}</string>" for key, value in values.items()]
entries += ["<key>onboarding</key><false/>", "<key>auto_connect</key><integer>1</integer>",
            "<key>switch_locked</key><false/>"]
Path(sys.argv[1]).write_text("<dict>\n" + "\n".join(entries) + "\n</dict>\n")
PY
sudo mkdir -p "$mdm_dir"
sudo install -m 600 "$state/mdm.xml" "$mdm_dir/mdm.xml"
rm -f "$state/mdm.xml"

case "$RUNNER_OS" in
  Linux)
    curl -fsSL --retry 3 https://pkg.cloudflareclient.com/pubkey.gpg \
      -o "$state/cloudflare-warp.gpg"
    sudo gpg --batch --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg \
      "$state/cloudflare-warp.gpg"
    printf 'deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ %s main\n' \
      "$(lsb_release -cs)" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list > /dev/null
    sudo chmod 644 /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg /etc/apt/sources.list.d/cloudflare-client.list
    sudo apt-get update -qq
    sudo apt-get install -y cloudflare-warp
    sudo systemctl restart warp-svc
    ;;
  macOS)
    brew install --cask cloudflare-warp
    sudo launchctl kickstart -k system/com.cloudflare.1dot1dot1dot1.macos.warp.daemon
    ;;
esac

# MDM service-token enrollment is asynchronous. Do not create a consumer registration.
connected=false
for _ in {1..60}; do
  if sudo warp-cli --accept-tos registration show > /dev/null 2>&1 &&
    sudo warp-cli --accept-tos status 2>/dev/null | grep -Eq '(^|: )Connected$'; then
    connected=true
    break
  fi
  sleep 2
done
if [[ "$connected" != true ]]; then
  sudo warp-cli --accept-tos status || true
  echo '::error::WARP did not connect. Check CF_TEAM_NAME, Service Auth device enrollment permissions, and the CI device profile.'
  exit 1
fi
