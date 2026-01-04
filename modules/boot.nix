{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "amd_pstate=active"
  ];

  # lanzaboote for secure boot
  boot.loader.systemd-boot.enable = false;
  boot.lanzaboote = {
    enable = true;
    # secure boot keys (v1.0.0 community standard location)
    pkiBundle = "/var/lib/sbctl";
  };

  boot.loader.efi.canTouchEfiVariables = true;
  # initrd systemd
  boot.initrd.systemd.enable = true;
  boot.tmp.cleanOnBoot = true;
}
