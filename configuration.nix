{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Kernel Version
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Boot Parameters
  boot.kernelParams = [ "split_lock_detect=off" "amd_pstate=active" ];

  # Power Management
  services.power-profiles-daemon.enable = false;
  powerManagement.cpuFreqGovernor = "powersave";
  systemd.tmpfiles.rules = [
  "w /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference - - - - balance_performance"
];


  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # SSD Trim
  services.fstrim.enable = true;

  # Storage Optimization
  nix.settings.auto-optimise-store = true;

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.initrd.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = pkgs.lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Swap
  zramSwap.enable = true;

  # Firewall
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # Networking
  networking.hostName = "nixos-orion";
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    connectionConfig = {
      "ipv4.ignore-auto-dns" = true;
      "ipv6.ignore-auto-dns" = true;
    };
  };

  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:53000" "[::1]:53000" ];
      server_names = [ "cloudflare" "quad9-dnscrypt-ip4-filter-pri" ];
      ipv4_servers = true;
      ipv6_servers = true;
      dnscrypt_servers = true;
      doh_servers = true;
      require_dnssec = true;
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
    dnsovertls = "false";
    fallbackDns = [ ];
    extraConfig = ''
      DNS=127.0.0.1:53000
      DNSStubListener=yes
    '';
  };

  services.tailscale.enable = true;

  # Localization
  time.timeZone = "America/Chicago";
  time.hardwareClockInLocalTime = true;
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Desktop Environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Sound and Printing
  services.printing.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User Account
  users.users.jack = {
    isNormalUser = true;
    description = "jack";
    extraGroups = [ "networkmanager" "wheel" "video" ];
  #  packages = with pkgs; [];
  };

  # Nixpkgs Config
  nixpkgs.config.allowUnfree = true;

  # Fonts
  fonts.packages = with pkgs; [
    # Nerd Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code

    # Manual Google Sans Installation
    (runCommand "google-sans-manual" {} ''
      mkdir -p $out/share/fonts/truetype
      cp ${./fonts/Google_Sans}/*.ttf $out/share/fonts/truetype
    '')

    # Standard Web & UI Fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    roboto
    inter

    # Microsoft Core Fonts
    corefonts
  ];

  # System Packages
  environment.systemPackages = with pkgs; [
    git
    btop
    fastfetch
    nil
    nix-output-monitor
  ];

  programs.firefox.enable = true;

  # Nix Helper
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/jack/nixos-config";
  };

  environment.variables.NH_FLAKE = "/home/jack/nixos-config";

  system.stateVersion = "25.11";
}
