{
  pkgs,
  ...
}:
{
  imports = [
    #    ./ssh.nix
    ./attic.nix
    ./git.nix
    ./nvim.nix
    ./zsh.nix
    ./tmux.nix
    ./direnv.nix
    ./llm
    ./notify-command-done.nix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    sops
    age
    ssh-to-age
    nodejs
    fastfetch
    htop
    kubectl
    kubernetes-helm
    peco
    nmap
    ripgrep
    gh
    jq
  ];
}
