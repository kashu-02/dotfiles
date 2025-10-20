{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
#    ./ssh.nix
    ./git.nix
    ./nvim.nix
    ./zsh.nix
    ./tmux.nix
    ./direnv.nix
  ];

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
      codex
    ]);
}
