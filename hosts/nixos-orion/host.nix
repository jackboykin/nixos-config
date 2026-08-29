{hostname, ...}: {
  imports = [./hardware-configuration.nix];
  networking.hostName = hostname;
  system.stateVersion = "26.05";

  fileSystems."/".options = ["noatime"];
  services.fstrim.enable = true;
  zramSwap.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c547", ATTR{power/wakeup}="disabled"
  '';
}
