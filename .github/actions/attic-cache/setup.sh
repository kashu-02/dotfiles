#!/usr/bin/env bash
set -euo pipefail

# Fork and Dependabot PRs do not receive these secrets.
if [[ -z "$CF_ACCESS_CLIENT_ID" || -z "$CF_ACCESS_CLIENT_SECRET" || -z "$ATTIC_TOKEN" ]]; then
  echo '::notice::Attic credentials are unavailable; using the existing caches.'
  echo 'enabled=false' >> "$GITHUB_OUTPUT"
  exit 0
fi

if [[ ! "$CF_TEAM_NAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*$ ]]; then
  echo '::error::Set CF_TEAM_NAME to the Zero Trust team name, without .cloudflareaccess.com.'
  exit 1
fi
if [[ ! "$ATTIC_HOSTNAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]]; then
  echo '::error::Attic hostname must be a DNS name without a scheme, port, or path.'
  exit 1
fi

umask 077
state="$RUNNER_TEMP/attic-ci"
mkdir -p "$state"
# Fetch the Attic client before changing the runner's network configuration.
nix build --inputs-from . nixpkgs#attic-client --out-link "$state/attic"
echo "$state/attic/bin" >> "$GITHUB_PATH"

bash "$(dirname "$0")/setup-warp.sh"
endpoint="http://$ATTIC_HOSTNAME"

# Nix uses HTTP Basic authentication (netrc); Attic accepts the JWT as password.
printf 'machine %s login ci password %s\n' "$ATTIC_HOSTNAME" "$ATTIC_TOKEN" > "$state/netrc"
ready=false
for _ in {1..12}; do
  if curl --silent --show-error --fail --max-time 5 --noproxy '*' \
    --netrc-file "$state/netrc" "$endpoint/main/nix-cache-info" \
    -o "$state/cache-info" && grep -q '^StoreDir: /nix/store' "$state/cache-info"; then
    ready=true
    break
  fi
  sleep 1
done
if [[ "$ready" != true ]]; then
  echo '::error::Attic is unreachable. Check the private hostname route, WARP DNS/Split Tunnels, Gateway policies, and Attic token.'
  exit 1
fi

# Attic push follows the advertised API endpoint; require the same private hostname.
curl --silent --show-error --fail --max-time 15 --noproxy '*' \
  --netrc-file "$state/netrc" "$endpoint/_api/v1/cache-config/main" \
  -o "$state/cache-config.json"
jq -e --arg endpoint "$endpoint/" '.api_endpoint == $endpoint' "$state/cache-config.json" > /dev/null || {
  echo "::error::Attic must advertise $endpoint/. Check api-endpoint and allowed-hosts on the server."
  exit 1
}

{
  echo 'NIX_CONFIG<<ATTIC_NIX_CONFIG'
  printf '%s\n' "${NIX_CONFIG:-}"
  echo "extra-substituters = $endpoint/main"
  echo 'extra-trusted-public-keys = main:MzopzMh+cafOLvaAuu4lETTyiSJQ/PUXaigUkHTCO8g='
  echo "netrc-file = $state/netrc"
  echo 'connect-timeout = 5'
  echo 'fallback = true'
  echo 'ATTIC_NIX_CONFIG'
} >> "$GITHUB_ENV"
echo "ATTIC_ENDPOINT=$endpoint/" >> "$GITHUB_ENV"
echo 'enabled=true' >> "$GITHUB_OUTPUT"
