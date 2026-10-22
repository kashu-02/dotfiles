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
    ./llm/chatgpt.nix
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
    unstable.jetbrains-toolbox
    xclip
    wine
    flameshot
    unstable.antigravity-hub
    unstable.antigravity-ide-fhs
  ];
}
