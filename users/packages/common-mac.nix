{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./git.nix
    ./nvim.nix
    ./tmux.nix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  nixpkgs.config.allowUnfree = true;
  home.packages =
    (with pkgs; [
      nodejs
      fastfetch
      htop
      kubectl
      kubernetes-helm
      peco
    ])
    ++ (with pkgs.unstable; [
      gemini-cli
      claude-code
    ]);
}
