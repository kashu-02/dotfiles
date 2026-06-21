{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:

{
  imports = [
    ./waybar.nix
  ];

  home.packages = [
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.grimblast
  ];

  programs.kitty.enable = true;
  home.file.".local/bin/pick_wallpaper.sh" = {
    source = ./pick_wallpaper.sh;
    executable = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    systemd.enable = false;
    extraConfig = ''
      submap = resize
      binde = , h, resizeactive, -40 0
      binde = , j, resizeactive, 0 40
      binde = , k, resizeactive, 0 -40
      binde = , l, resizeactive, 40 0
      binde = SHIFT, h, resizeactive, -120 0
      binde = SHIFT, j, resizeactive, 0 120
      binde = SHIFT, k, resizeactive, 0 -120
      binde = SHIFT, l, resizeactive, 120 0
      bind = , escape, submap, reset
      bind = , return, submap, reset
      bind = , r, submap, reset
      submap = reset
    '';
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
      "${pkgs.bash}/bin/bash -lc '/home/${config.home.username}/.local/bin/pick_wallpaper.sh; while sleep 3600; do /home/${config.home.username}/.local/bin/pick_wallpaper.sh; done'"
      "fcitx5 -d"
      "[workspace 9 silent] thunderbird"
      "[workspace 8 silent] discord --start-minimized"
      "[workspace 7 silent] slack"
      "jetbrains-toolbox"
    ];
    bind = [
      "$mod, RETURN, exec, $term"
      "$mod, G, exec, google-chrome-stable"
      "$mod SHIFT, F4, exec, grimblast copy area"
      "$mod, D, exec, rofi -show combi"
      "$mod, H, movefocus, l"
      "$mod, J, movefocus, d"
      "$mod, K, movefocus, u"
      "$mod, L, movefocus, r"
      "$mod SHIFT, H, movewindow, l"
      "$mod SHIFT, J, movewindow, d"
      "$mod SHIFT, K, movewindow, u"
      "$mod SHIFT, L, movewindow, r"
      "$mod ALT, H, swapwindow, l"
      "$mod ALT, J, swapwindow, d"
      "$mod ALT, K, swapwindow, u"
      "$mod ALT, L, swapwindow, r"
      "$mod, F, fullscreen, 1"
      "$mod, R, submap, resize"
      "$mod, SPACE, togglefloating"
      "$mod, V, pseudo"
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
      wallpaper = {
        monitor = "DP-1";
        path = "/home/${config.home.username}/.wallpapers/current_wallpaper";
      };
      ipc = true;
    };
  };
}
