{ pkgs, ... }:
let
  inherit (pkgs.stdenv) isDarwin;
in
{
  nix.settings = {
    trusted-users = [
      "root"
      "@wheel"
      "kashu"
      "shun"
    ];

    # attic use main が生成する netrc をシステム (nix-daemon / sudo 実行時) からも参照する
    netrc-file = if isDarwin then "/Users/shun/.config/nix/netrc" else "/home/kashu/.config/nix/netrc";

    extra-substituters = [
      "http://attic.kashu.internal/main"
    ];

    extra-trusted-public-keys = [
      "main:MzopzMh+cafOLvaAuu4lETTyiSJQ/PUXaigUkHTCO8g="
    ];

    # 内部ネットワーク外 (attic.kashu.internal 不達時) でも即座にフォールバックさせる
    connect-timeout = 5;
    fallback = true;
  };
}
