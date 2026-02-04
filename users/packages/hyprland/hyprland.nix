{ inputs, pkgs, config, lib, ... }:

{
  imports = [
    ./waybar.nix
  ];

  home.packages = [
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.kitty.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
  };

  programs.zsh.loginExtra = lib.mkAfter ''
    if uwsm check may-start && uwsm select; then
      exec uwsm start default
    fi
  '';


  wayland.windowManager.hyprland.settings = {
    "$term" = "wezterm";
    "$mod" = "SUPER";

    exec-once = [
      "fcitx5 -d"
      "[workspace 9 silent] thunderbird"
      "[workspace 8 silent] discord --start-minimized"
      "[workspace 7 silent] slack"
      "jetbrains-toolbox"
    ];
    bind =
      [
        "$mod, RETURN, exec, $term"
        "$mod, G, exec, google-chrome-stable"
        "$mod SHIFT, F4, exec, grimblast copy area"
        "$mod, D, exec, rofi -show combi"
        "$mod SHIFT, Q, killactive"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (
          builtins.genList (
            i:
            let
              ws = i + 1;
            in
            [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          ) 9
        )
      );

    animation = [
      "workspaces, 0, 0, default"
    ];

    monitor = "DP-1, 3840x2160@60, 0x0, 1.2";
    xwayland.force_zero_scaling = true;
    env = [
      "GDK_SCALE,2"
      "XCURSOR_SIZE,64"
    ];
    input.natural_scroll = false;
  };

  home.sessionVariables.NIXOS_OZONE_WL = 1;

  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 1;
        timeout = 5;
        offset = "30x30";
        transparency = 10;
        corner_radius = 10;
        font = "Noto Sans CJK JP";
      };
    };
  };
  
  services.hyprpaper = {
    enable = true;
    package = inputs.hyprpaper.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      wallpapers = [
         "DP-1,/home/${config.home.username}/.wallpapers/wallpaper"
      ];
    };
  };
}
