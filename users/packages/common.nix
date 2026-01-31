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
    ./notify-command-done.nix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages =
    (with pkgs; [
      nodejs
      fastfetch
      htop
      kubectl
      kubernetes-helm
      peco
      nmap
      ripgrep
    ])
    ++ (with pkgs.unstable; [
      gemini-cli
      claude-code
      codex
      opencode
    ]);
}
