{ pkgs, ... }:

{
  imports = [
    ./waybar.nix
  ];

  wayland.windowManager.hyprland.enable = true; # enable Hyprland

  wayland.windowManager.hyprland.settings = {
    "$term" = "wezterm";
    "$mod" = "SUPER";

    exec-once = [
      "waybar"
    ];
    bind =
      [
        "$mod, RETURN, exec, $term"
        "$mod, G, exec, google-chrome-stable"
        ", Print, exec, grimblast copy area"
        "$mod, D, exec, rofi -show combi"
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
    monitor = "DP-1, 3840x2160@60, 0x0, 1.2";
    xwayland.force_zero_scaling = true;
    env = [
      "GDK_SCALE,2"
      "XCURSOR_SIZE,32"
    ];
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
}
