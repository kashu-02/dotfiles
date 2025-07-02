{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./vscode.nix
    ./wezterm.nix
    ./rofi.nix
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
    htop
    jetbrains-toolbox
    xclip
    maim
    wine
  ];
}
