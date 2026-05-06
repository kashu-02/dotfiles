# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./l390-laptop-hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  
  boot.initrd.systemd.enable = true;

  boot.kernelParams = [
    "zswap.enabled=1" # enables zswap
    "zswap.compressor=lz4" # compression algorithm
    "zswap.max_pool_percent=20" # maximum percentage of RAM that zswap is allowed to use
    "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
  ];

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking = {
    hostName = "l390-laptop";
    # wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      # wifi.backend = "iwd";
    };
    nameservers = [
      "172.16.10.254"
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
  programs.nm-applet.enable = true;

  networking.wireguard = {
    enable = true;
    interfaces = {
      # network interface name.
      # You can name the interface arbitrarily.
      wg0 = {
        # MTU
        mtu = 1400;

        # the IP address and subnet of this peer
        ips = [ "10.100.0.8/32" "2401:2d60:3:14f::8/128" ];

        # WireGuard Port
        # Must be accessible by peers
        listenPort = 51820;

        # Path to the private key file.
        #
        # Note: can also be included inline via the privateKey option,
        # but this makes the private key world-readable;
        # using privateKeyFile is recommended.
        privateKeyFile = "/home/kashu/wireguard/privatekey";

        peers = [
          {
            name = "home";
            publicKey = "guS5P16cILWXSNXWttsrqyUagoRQA9pB1FXUeM6exls=";
            allowedIPs = [
              "10.100.0.1/32"
              "172.16.10.0/24"
              "192.168.20.0/24"
              "192.168.2.0/24"
            ];
            endpoint = "103.26.27.245:51820";
#            endpoint = "wg.kashu.dev:51820";
#           endpoint = "[240b:13:3ea0:500:be24:11ff:feed:bf9b]:51820";
            #  ToDo: route to endpoint not automatically configured
            # https://wiki.archlinux.org/index.php/WireGuard#Loop_routing
            # https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577
            # Send keepalives every 25 seconds. Important to keep NAT tables alive.
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  # dispatcherから systemctl / nmcli / wg を確実に呼ぶため
  systemd.services.NetworkManager-dispatcher.path = with pkgs; [
    systemd
    notify-desktop
    networkmanager
    coreutils
    glibc
    gnugrep
    gawk
    util-linux
  ];

  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "wireguard-auto-by-network" ''
        IFACE="$1"
        ACTION="$2"

        WG_SERVICE="wireguard-wg0.service"
        HOME_SSID="ks-wifi_5ghz"
        CURRENT_SSID="$(nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2-)"

        notify_active_user() {
          local message="$1"
          local session_id
          local session_user
          local session_uid
          local runtime_dir
          local session_bus

          for session_id in $(loginctl list-sessions --no-legend | awk '{print $1}'); do
            [ "$(loginctl show-session "$session_id" -p Active --value 2>/dev/null)" = "yes" ] || continue
            [ "$(loginctl show-session "$session_id" -p Class --value 2>/dev/null)" = "user" ] || continue

            session_user="$(loginctl show-session "$session_id" -p Name --value 2>/dev/null)"
            [ -n "$session_user" ] || continue

            session_uid="$(id -u "$session_user" 2>/dev/null)" || continue
            runtime_dir="/run/user/$session_uid"
            session_bus="unix:path=$runtime_dir/bus"

            [ -S "$runtime_dir/bus" ] || continue

            runuser -u "$session_user" -- env \
              XDG_RUNTIME_DIR="$runtime_dir" \
              DBUS_SESSION_BUS_ADDRESS="$session_bus" \
              notify-desktop "$message" || true
            return 0
          done

          return 1
        }

        case "$ACTION" in
          up|connectivity-change)
            if [ "$CURRENT_SSID" = "$HOME_SSID" ]; then
              systemctl stop "$WG_SERVICE"
              notify_active_user "WireGuard Tunnel Stopped"
            else
              systemctl start "$WG_SERVICE"
              notify_active_user "WireGuard Tunnel Started"
            fi
            ;;
          down)
              systemctl stop "$WG_SERVICE"
              notify_active_user "WireGuard Tunnel Stopped"
            ;;
        esac
      '';
      type = "basic";
    }
  ];

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Bluetooth Settings
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Brightness
  programs.light.enable = true;

  # Input devices
  hardware.trackpoint = {
    enable = true;
    emulateWheel = true;
    speed = 1;
    sensitivity = 1;
    device = "Elan TrackPoint";
  };

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";
  time.hardwareClockInLocalTime = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-skk
      fcitx5-gtk
      libsForQt5.fcitx5-qt
    ];
  };
  fonts.packages = with pkgs; [
    ipafont
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    jetbrains-mono
  ];

  environment.pathsToLink = [ "/libexec" ];

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkb = {
      variant = "";
      options = "ctrl:nocaps";
      layout = "us";
    };
    desktopManager = {
      xterm.enable = false;
    };
    windowManager.i3 = {
      enable = true;
      extraSessionCommands = ''
        xinput --set-prop 10 'libinput Accel Speed' 0.3
      '';
      extraPackages = with pkgs; [
        rofi
        polybar
        i3lock
      ];
    };
  };

  services.displayManager = {
    defaultSession = "none+i3";
  };

  services.libinput = {
    enable = true;
    touchpad.disableWhileTyping = true;
  };

  # Configure console keymap
  console.keyMap = "us";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kashu = {
    isNormalUser = true;
    description = "kashu";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "docker"
    ];
    packages = with pkgs; [ ];
  };
  nix.settings.allowed-users = [ "kashu" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    emacs
    wget
    openssl
    zip
    unzip
    traceroute
    dig
  ];

  # Nix-ld
  programs.nix-ld.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # nix storag optimization
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 90d";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleLidSwitch = "suspend";
    KillUserProcesses = false;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
