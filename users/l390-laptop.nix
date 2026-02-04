{ pkgs, ... }:

{
  imports = [
    ./packages/common.nix
    ./packages/common-linux.nix
    ./packages/linux-desktop.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "kashu";
  home.homeDirectory = "/home/kashu";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "22.11"; # Please read the comment before changing.

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/kashu/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.i3status-rust = {
    enable = true;
    bars = {
      top = {
        blocks = [
          {
            block = "battery";
            format = " $icon $percentage.eng(w:5) ";
            full_format = " $icon $percentage.eng(w:5) ";
            charging_format = " $icon $percentage.eng(w:5) ";
            empty_format = " $icon $percentage.eng(w:5) ";
            not_charging_format = " $icon $percentage.eng(w:5) ";
            missing_format = "";
            interval = 1;
            driver = "sysfs";
          }
          {
            block = "cpu";
          }
          {
            block = "memory";
            format = " $icon $mem_total_used.eng(w:2) ";
            format_alt = " $icon_swap $swap_used_percents.eng(w:2) ";
          }
          {
            block = "sound";
            driver = "pulseaudio";
          }
          {
            block = "net";
            format = " $icon {$signal_strength $ssid|Wired} ipv4: $ip ipv6: $ipv6 ";
          }
          {
            block = "time";
            interval = 5;
            format = " $timestamp.datetime(f:'%m/%d (%a) %T')";
          }
        ];
        theme = "gruvbox-dark";
      };
    };
  };

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-top.toml";
        }
      ];
      startup = [
        {
          command = "nm-applet";
          notification = false;
        }
        {
          command = "fcitx5 -d";
          notification = false;
        }
        {
          command = "xinput set-button-map 'Elan TrackPoint' 1 0 3 4 5 6 7 && xinput --set-prop\"Elan TrackPoint\" \"libinput Accel Speed\" 0.8";
          notification = false;
        }
      ];
      modifier = "Mod4";
      terminal = "wezterm";
      menu = "rofi -show combi";
    };
  };

  programs.neovim = {
    enable = true;
    plugins = [
      pkgs.vimPlugins.coc-nvim
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
