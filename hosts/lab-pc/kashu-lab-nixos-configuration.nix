# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./kashu-lab-nixos-hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "kashu-lab-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = false;

  networking.interfaces.enp1s0 = {
    ipv4.addresses = [
      {
        address = "192.168.50.100";
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = {
    address = "192.168.50.1";
  };
  networking.nameservers = [ "192.168.50.1" ];

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
    LC_TIME = "ja_JP.UTF-8";
  };

  # IME
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      #   libsForQt5.fcitx5-qt
    ];
  };

  fonts.packages = with pkgs; [
    ipafont
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    xkbOptions = "ctrl:nocaps, ";
    dpi = 130;
    libinput.mouse.accelSpeed = "0.8";
    desktopManager = {
      xterm.enable = false;
    };
    displayManager = {
      defaultSession = "none+i3";
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        rofi
        polybar
        i3lock
      ];
    };
  };

  environment.pathsToLink = [ "/libexec" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kashu = {
    isNormalUser = true;
    description = "kashu";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "docker"
      "libvirtd"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };

  users.groups.nfsgroup = {
    members = [ "kashu" ];
    gid = 1000;
  };

  # Shell settings
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    wezterm
    openssl
    zip
    unzip
    traceroute
    dig
  ];

  # Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Nix-ld for such as VSCode
  programs.nix-ld.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # libvirt
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Nix Storage Optimization
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 90d";
  };

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

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 56755 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      X11Forwarding = true;
    };
  };

  services.ollama.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
