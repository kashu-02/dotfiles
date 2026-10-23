# CI から自宅の Attic を利用する

GitHub Actions の Linux／macOS runner を Cloudflare WARP に Service Token で登録し、Private hostname route 経由で `attic.kashu.internal` に接続する。Nix は `main` キャッシュから取得し、main ブランチへの push では成功したビルドの closure を Attic に送信する。既存の GitHub Actions キャッシュも併用する。

```text
Nix / attic → http://attic.kashu.internal
            → runner の WARP → Cloudflare Gateway
            → Private hostname route → 自宅 cloudflared → Attic
```

## 自宅と Cloudflare の設定

1. 自宅の `cloudflared` を **2025.7.0 以降**にする。実行ホスト（コンテナならそのコンテナ）から `attic.kashu.internal` を内部 IP に名前解決でき、HTTP のポート 80 に接続できることを確認する。
2. 既存 Tunnel の **Routes → Add route → Private hostname** に `attic.kashu.internal` を登録する。ホストの system resolver で名前解決できるため、追加の DNS サーバー用 IP/CIDR route や Gateway resolver policy は不要。
3. **Traffic policies → Traffic settings → Proxy and inspection** で Gateway proxy の TCP／UDP を有効にする。
4. **Team & Resources → Devices → Management → Device enrollment permissions** で、CI 用 Service Token を許可するポリシーを作成して紐付ける。Action は **Service Auth**、Include は **Service Token → 対象トークン**にする。既存の `CF_ACCESS_CLIENT_ID`／`CF_ACCESS_CLIENT_SECRET` を再利用する場合も、Published application の Access ポリシーとは別にこの登録許可が必要。
5. CI runner に適用する WARP device profile を設定する。
   - 動作モードは **Traffic and DNS**（スクリプトの MDM 設定で `service_mode=warp` を指定）。
   - Split Tunnels は **Include** を使い、アカウントの initial resolved IP 範囲を含める。現在のデフォルトは IPv4 `172.64.128.0/20`、IPv6 `2606:4700:0cf1:4000::/64`。旧デフォルトやカスタム範囲を使用している場合は、実際の設定値に合わせる。GitHub などへの通常通信は直接接続する。
   - Local Domain Fallback に `internal`、`kashu.internal`、`attic.kashu.internal` など、このホストに一致するエントリがあれば外す。名前解決を Gateway に送る必要がある。
6. Gateway のネットワーク／DNS ポリシーで、CI 端末から Attic への接続を許可する。端末登録許可とアプリケーションへの接続許可は別の設定。Attic は HTTP のため、HTTPS 用の SNI 条件だけでは制御できない。必要な宛先 IP・ポートに絞った許可と、他の内部宛先への拒否を設定する。

この CI では Published application の `attic.kashu.dev` や `cloudflared access tcp` は使わない。既存の Published application は、他の用途で使っていないことを確認したうえで別途削除できる。

## Attic サーバー

既存の内部 URL をそのまま使う。`allowed-hosts` に `attic.kashu.internal` を含め、API が返す `api_endpoint` を `http://attic.kashu.internal/` に揃える。例えば、固定する場合は以下の設定にする。

```toml
allowed-hosts = ["attic.kashu.internal"]
api-endpoint = "http://attic.kashu.internal/"
substituter-endpoint = "http://attic.kashu.internal/"
```

他のクライアントが必要とする `allowed-hosts` は残す。エンドポイントを固定せず Host から生成する既存構成でも、同じ内部 URL が返れば利用できる。CI は API の返す URL を検査するため、以前の `127.0.0.1:18080` が残っていると失敗する。リバースプロキシを使う場合も、この内部 Host で Attic へルーティングする。

## GitHub Actions の設定

Repository Settings → Secrets and variables → Actions に登録する。

| 種別 | 名前 | 内容 |
| --- | --- | --- |
| Variable | `CF_TEAM_NAME` | Zero Trust のチーム名。`https://` や `.cloudflareaccess.com` を付けない |
| Secret | `CF_ACCESS_CLIENT_ID` | WARP 端末登録を許可した Service Token の Client ID |
| Secret | `CF_ACCESS_CLIENT_SECRET` | 同トークンの Client Secret |
| Secret | `ATTIC_TOKEN` | Attic の `main` に pull／push 権限を持つ JWT（取得・送信で共用） |

Tunnel のコネクタートークンや Attic の JWT 署名鍵を GitHub に登録する必要はない。Attic サーバーで期限付きトークンを発行する例:

```sh
atticadm -f /path/to/server.toml make-token --sub github-ci --validity 90d --pull main --push main
```

Service Token と Attic JWT は有効期限前に更新する。キャッシュ署名公開鍵は `hosts/common/nix-cache.nix` と同じ値を setup.sh に設定している。鍵をローテーションした場合は両方を更新する。

## 実行と確認

- 対象は使い捨ての GitHub-hosted Ubuntu／macOS runner。WARP は Linux では Cloudflare 公式 APT リポジトリ、macOS では Homebrew の `cloudflare-warp` cask から導入する。Attic クライアントはフレークに固定された nixpkgs から取得する。
- Secrets がない実行（fork PR、通常の Dependabot PR、導入前）は自宅キャッシュをスキップする。Secrets が揃っている状態で `CF_TEAM_NAME` が未設定、登録・接続・Attic 認証が失敗した場合はジョブを失敗させる。
- Service Token を含む MDM ファイルは root 所有・mode 600 で配置する。WARP の登録と Connected 状態を待ち、実際の `nix-cache-info` と API 応答を検査してからキャッシュを有効にする。
- PR では取得のみ実行するが、使用するトークン自体には pull／push 権限がある。`push` イベントの `refs/heads/main` はビルド成功後に `attic push ci:main ./result` を実行する。
- Repository Secrets は同一リポジトリの PR から変更された workflow でも参照できる。push ステップの条件は権限境界ではないため、書き込み権限のあるコントリビューターを信頼する構成。厳密な分離が必要なら pull 専用トークンを別途発行し、pull／push トークンを main 限定の GitHub Environment に置く専用ジョブへ分離する。
- 終了時は `always()` で MDM ファイル・Attic の認証ファイルを削除し、WARP の切断・登録削除・デーモン停止を行う。runner の強制終了や登録削除の失敗で残った端末は Zero Trust 側で確認・整理する。
- 導入後は Linux／macOS 両方の CI で接続と push の成功を確認し、次のビルドログで `http://attic.kashu.internal/main` から取得されることを確認する。既存キャッシュにあるパスは再取得されない。

疎通失敗時は、runner の `warp-cli --accept-tos status`、DNS 応答、Gateway のログ、Tunnel の状態を確認する。DNS は自宅の実 IP ではなく、アカウントの initial resolved IP 範囲のアドレスを返すことを確認する。

## 参照

- [Cloudflare private hostname 接続](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/private-net/cloudflared/connect-private-hostname/)
- [Service Token を使った WARP の無人登録](https://developers.cloudflare.com/cloudflare-one/tutorials/deploy-client-headless-linux/)
- [WARP の MDM 配置方法（Linux／macOS）](https://developers.cloudflare.com/cloudflare-one/team-and-resources/devices/cloudflare-one-client/deployment/mdm-deployment/)
- [WARP の MDM パラメーター](https://developers.cloudflare.com/cloudflare-one/team-and-resources/devices/cloudflare-one-client/deployment/mdm-deployment/parameters/)
- [Attic サーバーの endpoint と allowed-hosts](https://github.com/zhaofengli/attic/blob/main/server/src/config.rs)
