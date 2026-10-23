# CI から自宅の Attic を利用する

GitHub Actions の Linux／macOS ビルドは `attic.kashu.dev` の Cloudflare Access に Service Token で接続し、TCP トンネル越しに `main` キャッシュを取得する。main ブランチへの push では成功したビルドの closure を Attic に送信する。既存の GitHub Actions キャッシュも併用する。

```text
Nix / attic → 127.0.0.1:18080 → cloudflared access tcp
            → Cloudflare Access → 自宅 cloudflared → Attic
```

この構成では WARP、Private hostname route、端末登録、Split Tunnels、runner の内部 DNS 設定、`CF_TEAM_NAME` は不要。既存の Tunnel を利用し、CI は Published application の公開ホスト名へ接続する。

## 自宅と Cloudflare の設定

Attic VM の設定は [servers/hosts/attic/default.nix](https://github.com/kashu-02/servers/blob/main/hosts/attic/default.nix) で管理する。[servers PR #13](https://github.com/kashu-02/servers/pull/13) の TCP 接続対応に加え、[PR #14](https://github.com/kashu-02/servers/pull/14) の nginx Host 検証修正が必要。両方が取り込まれた `servers` checkout を VM 上で取得し、CI の Secrets を有効にする前に適用する。

```sh
git pull --ff-only
sudo nixos-rebuild switch --flake .#attic
```

マージだけでは稼働中の Attic／nginx 設定は変わらない。詳細は [servers の運用手順](https://github.com/kashu-02/servers/blob/main/docs/attic.md) を参照する。

1. 自宅の Attic に到達できるホストで Cloudflare Tunnel のコネクターを稼働させる。ルーターの受信ポート開放は不要。
2. Access に Self-hosted application `attic.kashu.dev` を作成する。CI 用 Service Token を発行し、**Service Auth** ポリシーの Include → Service Token でそのトークンを指定する。
3. Tunnel の Published application に `attic.kashu.dev` を登録する。Service は **TCP**、転送先は `attic.kashu.internal:80`（現在の内部 URL が指す HTTP サービス）。HTTP タイプではなく TCP タイプを選ぶ。Attic に直接つなぐ場合は実際のホストとポートに置き換える。
4. 転送先の nginx は `map` で受信 Host を `attic.kashu.internal` と `127.0.0.1:18080` の固定値に限定し、`proxy_set_header Host $attic_proxy_host` で転送する。これにより CI のポート番号を保持し、未許可 Host は nginx で拒否する。Attic 自体は VM の `127.0.0.1:8080` で待ち受けるため、別ホストの Tunnel コネクターからは nginx の TCP 80 に接続する。

Attic は API URL をクライアントに返し、push はその URL を使用する。CI の接続をローカルのトンネル内に維持するため、サーバーの `api-endpoint` と `substituter-endpoint` の固定値を外し、Host から URL を生成させる。代わりに `allowed-hosts` を必ず限定する。既存の内部クライアントの Host も残す。

```toml
allowed-hosts = ["attic.kashu.internal", "127.0.0.1:18080"]
# api-endpoint / substituter-endpoint は設定しない
```

これらは `servers` の NixOS 設定に反映済み。LAN クライアントには `http://attic.kashu.internal/`、CI には `http://127.0.0.1:18080/` を返す。CI は後者の API URL を検査する。

## GitHub Actions の Secrets

Repository Settings → Secrets and variables → Actions に登録する。

| Secret | 内容 |
| --- | --- |
| `CF_ACCESS_CLIENT_ID` | CI 用 Access Service Token の Client ID |
| `CF_ACCESS_CLIENT_SECRET` | 同トークンの Client Secret |
| `ATTIC_TOKEN` | Attic の `main` に pull／push 権限を持つ JWT（取得・送信で共用） |

Tunnel のコネクタートークンや Attic の JWT 署名鍵を GitHub に登録する必要はない。Attic VM 上で、NixOS が用意するラッパーから期限付きトークンを発行する:

```sh
sudo atticd-atticadm make-token --sub github-ci --validity '90 days' --pull main --push main
```

Service Token と Attic JWT は有効期限前に更新する。キャッシュ署名公開鍵は `hosts/common/nix-cache.nix` と同じ値を setup.sh に設定している。鍵をローテーションした場合は両方を更新する。

## 実行と確認

- Secrets がない実行（fork PR、通常の Dependabot PR、導入前）は自宅キャッシュをスキップする。
- 認証情報が揃っているのに接続／認証に失敗した場合は、設定不良を見逃さないようジョブを失敗させる。
- PR では取得のみ実行するが、使用するトークン自体には pull／push 権限がある。`push` イベントの `refs/heads/main` はビルド成功後に `attic push ci:main ./result` を実行する。closure の計算は Attic が行う。
- Repository Secrets は同一リポジトリの PR から変更された workflow でも参照できる。push ステップの条件は権限境界ではないため、書き込み権限のあるコントリビューターを信頼する構成。厳密な分離が必要なら pull 専用トークンを別途発行し、pull／push トークンを main 限定の GitHub Environment に置く専用ジョブへ分離する。
- 接続前にフレークに固定された nixpkgs から `cloudflared` と `attic-client` を取得する。接続後、実際の `nix-cache-info` と API 応答で疎通を検査する。
- 導入後は main の CI で push の完了を確認し、次の変更のビルドログで `http://127.0.0.1:18080/main` から取得されることを確認する。既存キャッシュにあるパスは再取得されない。

TCP は WebSocket 経由で転送される。長時間接続の安定性には制約があるため、切断が頻発する場合は Cloudflare の推奨する Client-to-Tunnel 方式を検討する。

## 参照

- [Cloudflare TCP 接続](https://developers.cloudflare.com/cloudflare-one/access-controls/applications/non-http/cloudflared-authentication/arbitrary-tcp/)
- [Cloudflare Service Tokens](https://developers.cloudflare.com/cloudflare-one/access-controls/service-credentials/service-tokens/)
- [cloudflared の Service Token オプション](https://github.com/cloudflare/cloudflared/blob/master/cmd/cloudflared/access/cmd.go)
- [Attic サーバーの endpoint と allowed-hosts](https://github.com/zhaofengli/attic/blob/main/server/src/config.rs)
