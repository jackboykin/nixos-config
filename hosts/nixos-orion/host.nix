{hostname, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = hostname;
  system.stateVersion = "25.11";
}
