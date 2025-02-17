{
  config,
  pkgs,
  ...
}: {
  imports = [
    vscode.nix
  ];

  home.packages = with pkgs; [
    google-chrome
    slack
    discord
    _1password-gui
    thunderbird
    vlc
    nodejs
    xarchiver
    gimp
    libreoffice
    bottom
    arandr
    pavucontrol
    evince
    tmux
    htop
    jetbrains-toolbox
    xclip
    maim
    wine
  ];
}
