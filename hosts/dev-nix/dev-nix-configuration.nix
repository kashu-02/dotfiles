# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./dev-nix-hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  networking = {
    hostName = "dev-nix"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager.enable = true;

    interfaces = {
      ens18.ipv4 = {
        addresses = [
          {
            address = "172.16.10.10";
            prefixLength = 24;
          }
        ];
      };
      ens19.ipv4 = {
        addresses = [
          {
            address = "172.20.0.200";
            prefixLength = 24;
          }
        ];
      };
    };

    defaultGateway = {
      address = "172.16.10.1";
      interface = "ens18";
    };

    nameservers = [
      "172.16.10.254"
      "1.1.1.1"
      "1.0.0.1"
    ];

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    firewall.enable = false;
  };

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

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
    LC_TIME = "ja_JP.UTF-8";
  };

  fonts.packages = with pkgs; [
    ipafont
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # Configure keymap in X11
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
      xkb.variant = "";
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu
          i3status
          i3lock
        ];
      };
    };
    displayManager = {
      defaultSession = "none+i3";
    };

    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      ports = [ 56754 ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        X11Forwarding = true;
      };
    };

    prometheus.exporters.node = {
      enable = true;
      port = 9090;
      enabledCollectors = [ "systemd" ];
      extraFlags = [
        "--collector.ethtool"
        "--collector.softirqs"
        "--collector.tcpstat"
      ];
    };

    ollama = {
      enable = true;
      host = "0.0.0.0";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kashu = {
    isNormalUser = true;
    description = "kashu";
    extraGroups = [
      "networkmanager"
      "wheel"
      "nfsgroup"
      "video"
      "docker"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };

  users.groups.nfsgroup = {
    members = [ "kashu" ];
    gid = 1000;
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  # Enable nix-ld
  programs.nix-ld.enable = true;

  environment = {
    shells = with pkgs; [ zsh ];

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      openssl
      zip
      unzip
      traceroute
      dig
    ];

    # Set the default editor to vim
    variables.EDITOR = "vim";
  };

  # Enable Nix flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  fileSystems."/mnt/dev" = {
    device = "172.20.0.10:/mnt/dev-data/dev";
    fsType = "nfs4";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable docker vertualization
  virtualisation.docker.enable = true;

  # Nix Storage Optimization
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 90d";
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
