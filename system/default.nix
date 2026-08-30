_: {
  imports = [
    ./hardware.nix
    ./base.nix
    ./nix.nix
    ./boot.nix
    ./desktop.nix
    ./fonts.nix
    ./audio.nix
    ./networking.nix
    ./ntp.nix
    ./sysctl.nix
    ./musl.nix
  ];

  networking.hostName = "nixos-orion";
  system.stateVersion = "26.05";

  fileSystems."/".options = ["noatime"];
  services.fstrim.enable = true;
  zramSwap.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c547", ATTR{power/wakeup}="disabled"
  '';
}
