{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = ["amd_pstate=active"];
    tmp.cleanOnBoot = true;

    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    initrd.systemd.enable = true;
  };
  system.nixos-init.enable = true;
  system.etc.overlay.enable = true;
  services.userborn.enable = true;
}
