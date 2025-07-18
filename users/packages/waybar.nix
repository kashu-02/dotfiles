{ pkgs, ... }:

{
  programs.waybar.enable = true;

  programs.waybar.systemd.enable = true;

  programs.waybar.settings = {
    mainBar = {
      position = "top";
      height = 40;
      width = 2560;
      modules-left = [
        "hyprland/workspaces"
        "hyprland/submap"
      ];
      modules-center = [
        "hyprland/window"
      ];

      modules-right = [
        "network"
        "cpu"
        "memory"
        "temperature"
        "hyprland/language"
        "bluetooth"
        "privacy"
        "clock"
        "tray"
      ];

      clock = {
        format = "{:%H:%M:%S}";
        interval = 1;
        calendar = {
          mode = "year";
          mode-mon-col = 3;
          weeks-pos = "right";
          on-scroll = 1;
          format = {
            months = "<span color='#ffead3'><b>{}</b></span>";
            days = "<span color='#ecc6d9'><b>{}</b></span>";
            weeks = "<span color='#99ffdd'><b>W{}</b></span>";
            weekdays = "<span color='#ffcc66'><b>{}</b></span>";
            today = "<span color='#ff6699'><b><u>{}</u></b></span>";
          };
        };
        actions = {
          on-click-right = "mode";
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
      };
      cpu = {
        format = "CPU: {}%";
      };
      memory = {
        format = "Mem: {}%";
      };
      temperature = {
        format = "Temp: {temperatureC}°C";
      };
      network = {
        interface = "vlan100";
        format-ethernet = "↑ {bandwidthUpBits} / ↓ {bandwidthDownBits} | {bandwidthTotalBits}";
        format-disconnected = "Disconnected";
      };
      privacy = {
        modules = [
          {
            type = "screenshare";
          }
        ];
      };
    };
  };
}
