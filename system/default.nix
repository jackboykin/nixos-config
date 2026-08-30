_: {
  imports = [
    ./hardware.nix
    ./base.nix
    ./nix.nix
    ./boot.nix
    ./sysctl.nix
    ./musl.nix
    ./networking.nix
    ./ntp.nix
    ./desktop.nix
    ./audio.nix
    ./fonts.nix
  ];

  networking.hostName = "nixos-orion";
  system.stateVersion = "26.05";
}
