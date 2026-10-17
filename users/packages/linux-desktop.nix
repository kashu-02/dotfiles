{
  pkgs,
  ...
}:
{
  imports = [
    ./vscode.nix
    ./wezterm.nix
    ./rofi.nix
    ./ollama.nix
    ./udiskie.nix
  ];

  home.packages = with pkgs; [
    google-chrome
    slack
    discord
    _1password-gui
    thunderbird-bin
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
    unstable.jetbrains-toolbox
    xclip
    wine
    flameshot
  ];
}
