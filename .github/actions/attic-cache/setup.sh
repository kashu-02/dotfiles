#!/usr/bin/env bash
set -euo pipefail

# Fork and Dependabot PRs do not receive these secrets.
if [[ -z "$TUNNEL_SERVICE_TOKEN_ID" || -z "$TUNNEL_SERVICE_TOKEN_SECRET" || -z "$ATTIC_TOKEN" ]]; then
  echo '::notice::Attic credentials are unavailable; using the existing caches.'
  echo 'enabled=false' >> "$GITHUB_OUTPUT"
  exit 0
fi

umask 077
state="$RUNNER_TEMP/attic-ci"
mkdir -p "$state"
# Resolve both clients through the repository's locked nixpkgs input.
nix build --inputs-from . nixpkgs#cloudflared --out-link "$state/cloudflared"
nix build --inputs-from . nixpkgs#attic-client --out-link "$state/attic"
echo "$state/attic/bin" >> "$GITHUB_PATH"

nohup "$state/cloudflared/bin/cloudflared" access tcp \
  --hostname "$ATTIC_HOSTNAME" --url 127.0.0.1:18080 \
  > "$state/cloudflared.log" 2>&1 < /dev/null &
echo "$!" > "$state/tunnel.pid"

# Nix uses HTTP Basic authentication (netrc); Attic accepts the JWT as password.
printf 'machine 127.0.0.1 login ci password %s\n' "$ATTIC_TOKEN" > "$state/netrc"
ready=false
for i in {1..12}; do
  if curl --silent --fail --max-time 15 --noproxy '*' \
    --netrc-file "$state/netrc" http://127.0.0.1:18080/main/nix-cache-info \
    -o "$state/cache-info" 2>/dev/null && grep -q '^StoreDir: /nix/store' "$state/cache-info"; then
    ready=true
    echo "Connected to Attic cache on attempt $i."
    break
  fi
  echo "Waiting for Attic tunnel (attempt $i/12)..."
  sleep 1
done
if [[ "$ready" != true ]]; then
  echo '::group::cloudflared log'
  cat "$state/cloudflared.log" || true
  echo '::endgroup::'
  # Replay the WebSocket upgrade cloudflared sends, and show the edge's answer
  # without cookies or the Access JWT.
  echo '::group::WebSocket handshake response'
  curl --silent --show-error --http1.1 --max-time 15 --include --output - \
    -H "CF-Access-Client-Id: $TUNNEL_SERVICE_TOKEN_ID" \
    -H "CF-Access-Client-Secret: $TUNNEL_SERVICE_TOKEN_SECRET" \
    -H 'Connection: Upgrade' -H 'Upgrade: websocket' \
    -H 'Sec-WebSocket-Version: 13' -H 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' \
    "https://$ATTIC_HOSTNAME/" 2>&1 \
    | grep -viE '^(set-cookie|cf-access-jwt-assertion|cf-access-token|cookie):' | head -c 2000 || true
  echo
  echo '::endgroup::'
  echo '::error::Attic is unreachable. Check Tunnel TCP routing, Service Auth policy, and Attic token.'
  exit 1
fi

echo '::group::Attic cache info'
cat "$state/cache-info"
echo '::endgroup::'

# Attic push follows the advertised API endpoint. Reject any route outside the tunnel.
curl --silent --show-error --fail --max-time 15 --noproxy '*' \
  --netrc-file "$state/netrc" http://127.0.0.1:18080/_api/v1/cache-config/main \
  -o "$state/cache-config.json"
jq -e '."api_endpoint" == "http://127.0.0.1:18080/"' "$state/cache-config.json" > /dev/null || {
  echo '::error::Attic must advertise http://127.0.0.1:18080/. Unset api-endpoint on the server and allow the local Host header.'
  exit 1
}
echo "Attic API endpoint verified: $(jq -r '.api_endpoint' "$state/cache-config.json")"

{
  echo 'NIX_CONFIG<<ATTIC_NIX_CONFIG'
  printf '%s\n' "${NIX_CONFIG:-}"
  echo 'extra-substituters = http://127.0.0.1:18080/main'
  echo 'extra-trusted-public-keys = main:xPy89rS5DgJ4nmSBaYB8eSp9WQBeRGi8tKzRVTMWAtw='
  echo "netrc-file = $state/netrc"
  echo 'connect-timeout = 5'
  echo 'fallback = true'
  echo 'ATTIC_NIX_CONFIG'
} >> "$GITHUB_ENV"
echo 'enabled=true' >> "$GITHUB_OUTPUT"
