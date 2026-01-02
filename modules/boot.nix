{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "split_lock_detect=off"
    "amd_pstate=active"
  ];

  # lanzaboote for secure boot
  boot.loader.systemd-boot.enable = false;
  boot.lanzaboote = {
    enable = true;
    # secure boot keys
    pkiBundle = "/etc/secureboot";
  };

  boot.loader.efi.canTouchEfiVariables = true;
  # initrd systemd
  boot.initrd.systemd.enable = true;
}
