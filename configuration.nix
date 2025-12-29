{ _config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Kernel Version
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # SSD Trim
  services.fstrim.enable = true;

  # Storage Optimization
  nix.settings.auto-optimise-store = true;

  # Graphics
  boot.kernelParams = [ "split_lock_detect=off" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Necessary for Steam/Proton
  };
  hardware.amdgpu.initrd.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = pkgs.lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos-orion";
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.nameservers = [ "1.1.1.1#cloudflare-dns.com" "9.9.9.9#dns.quad9.net" ];
  services.tailscale.enable = true;

  # Custom DNS
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1#cloudflare-dns.com" "9.9.9.9#dns.quad9.net" ];
    extraConfig = ''
      DNSOverTLS=yes
    '';
  };

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

  # Improve audio compatibility
  services.pipewire.jack.enable = true;

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
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    noto-fonts
  ];

  # System Packages
  environment.systemPackages = with pkgs; [
    git
    btop
    fastfetch
    nil
  ];

  programs.firefox.enable = true;

  # NH (Nix Helper)
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/jack/nixos-config";
  };

  environment.variables.NH_FLAKE = "/home/jack/nixos-config";

  system.stateVersion = "25.11";
}
