# sops-nixによるシークレット管理

NixOS 4台とMac 1台で、SSHのEd25519ホスト鍵を復号に使います。
編集には `~/.config/sops/age/keys.txt` のage鍵を使います。
秘密鍵と平文はGitに登録せず、暗号化したYAMLと公開鍵だけを登録してください。

現在はモジュールとツールを追加した段階です。暗号化ファイルと `sops.secrets` は未定義のため、復号処理は起動しません。
Home Manager用のsopsモジュールは使っていません。

## 1. ツールと鍵を準備する

設定を各端末へ適用すると、`sops`・`age-keygen`・`ssh-to-age` が使えます。
適用前に使う場合は、リポジトリのルートで次を実行します。

```sh
nix shell nixpkgs#sops nixpkgs#age nixpkgs#ssh-to-age
```

編集用公開鍵は次のコマンドで確認できます。既存の秘密鍵は上書きしないでください。

```sh
age-keygen -y ~/.config/sops/age/keys.txt
```

Macでも `/etc/ssh/ssh_host_ed25519_key` を使います。鍵がない場合だけ、Mac上で生成します。
`ssh-keygen -A` は既存のホスト鍵を上書きせず、不足している種類を生成します。SSHのリモートログインを有効にする必要はありません。

```sh
sudo ssh-keygen -A
```

各端末で次を実行し、公開鍵をage形式に変換します。秘密鍵を編集用端末へコピーする必要はありません。

```sh
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

## 2. ホスト別の暗号化ルールを追加する

ファイル名は次の構成名に合わせます。

| 端末 | 暗号化ファイル |
| --- | --- |
| dev-nix | `secrets/dev-nix.yaml` |
| lab-pc | `secrets/kashu-lab-nixos.yaml` |
| l390-laptop | `secrets/l390-laptop.yaml` |
| nixos-desktop | `secrets/nixos-desktop.yaml` |
| MacBook Air | `secrets/Shunsukes-MacBook-Air.yaml` |

`.sops.yaml` の `keys` にホストの公開鍵を追加し、ホスト別ルールを初期ルールより前に置きます。
SOPSは最初に一致したルールを使います。次はnixos-desktopの例です。
`age1...` は取得した実際のホスト公開鍵へ置き換えてください。

```yaml
keys:
  - &admin 実際の編集用公開鍵（既存の値を維持）
  - &nixos_desktop age1...

creation_rules:
  - path_regex: ^secrets/nixos-desktop\.yaml$
    key_groups:
      - age:
          - *admin
          - *nixos_desktop
  # 初期ルールは最後に残す
  - path_regex: ^secrets/[^/]+\.yaml$
    key_groups:
      - age:
          - *admin
```

初期ルールは編集用鍵だけを対象とします。そのまま暗号化したファイルはホスト側で復号できません。
各ホストのルールを追加してからシークレットを有効にしてください。

リポジトリのルートで暗号化ファイルを作成します。

```sh
sops secrets/nixos-desktop.yaml
```

エディター内には、たとえば `example_token: 値` のように記載します。
保存後のファイルに `ENC[...]` と `sops` メタデータがあることを確認してください。
復号確認時は値を端末へ表示せず、出力を破棄できます。

```sh
sops decrypt secrets/nixos-desktop.yaml > /dev/null
```

## 3. ホストの設定から利用する

対象ホストの設定ファイルに定義を追加します。
`hosts/nixos-desktop/` と `hosts/macbookairm1/` のどちらからも、次の相対パスで参照できます。
Macではファイル名を `Shunsukes-MacBook-Air.yaml` に読み替えてください。

```nix
sops.secrets.example_token = {
  sopsFile = ../../secrets/nixos-desktop.yaml;
};
```

利用するモジュールの引数に `config` を加え、`config.sops.secrets.example_token.path` をサービスの秘密ファイル用オプションへ渡します。
既定ではrootのみが読めます。ユーザーが利用する場合は `owner` を指定します（NixOSは `"kashu"`、Macは `"shun"`）。
サービスに必要な再起動などは、実際の利用先を追加する際に設定してください。
秘密情報を `builtins.readFile` で読み込んだり、`home.file.*.text` や環境変数のNix定義に埋め込んだりしないでください。
平文がNix storeへ入ってしまいます。

新しいファイルはflakeから参照できるようGitへ登録してからビルドします。

```sh
git add .sops.yaml secrets/nixos-desktop.yaml
nix build .#nixosConfigurations.nixos-desktop.config.system.build.toplevel
sudo nixos-rebuild switch --flake .#nixos-desktop
```

Macでは次を使います。実際に反映するときだけ `switch` を実行してください。

```sh
nix build .#darwinConfigurations.Shunsukes-MacBook-Air.system
sudo darwin-rebuild switch --flake .#Shunsukes-MacBook-Air
```

## 鍵の追加・交換と復旧

- 公開鍵を追加・交換したら `.sops.yaml` を変更し、編集用鍵が使える端末で `sops updatekeys secrets/<ホスト名>.yaml` を実行します。ルールの変更だけでは既存ファイルの受信者は変わりません。
- 編集用age秘密鍵はリポジトリの外にバックアップしてください。ホスト鍵も安全な別の場所に保管し、復元時の所有者をroot、秘密鍵の権限を `0600` にします。
- 端末を再インストールした場合は、最初の復号前に以前のホスト鍵を復元するか、新しいホスト公開鍵を登録して `sops updatekeys` を実行します。編集用鍵があれば新しいホスト鍵向けに暗号化し直せます。
- 鍵の漏えい時は受信者の削除だけで終えず、`sops rotate -i secrets/<ホスト名>.yaml` と実際の認証情報の変更も行います。過去のGit履歴にある暗号文は削除した受信者でも復号できるためです。

`.gitignore` は `secrets/` 直下の `*.plain.*`、`*.decrypted.*`、`*.key`、`keys.txt`、SSH秘密ホスト鍵を除外します。
別名の平文まで自動で見分けるものではないため、コミット前に差分を確認してください。

仕様は [sops-nix](https://github.com/Mic92/sops-nix) と [SOPS](https://getsops.io/docs/) を参照してください。
