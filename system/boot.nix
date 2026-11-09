{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackagesFor pkgs.linux-orion;
    kernelParams = [
      "SYSTEMD_DEFAULT_MOUNT_RATE_LIMIT_BURST=50"
    ];

    loader = {
      timeout = 0;
      efi.canTouchEfiVariables = true;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    initrd = {
      includeDefaultModules = false;
      systemd.tpm2.enable = false;
    };
    tmp.cleanOnBoot = true;
    kexec.enable = false;
  };

  system = {
    nixos-init.enable = true;
    etc.overlay.enable = true;
  };

  systemd.tpm2.enable = false;
  services.lvm.enable = false;
}
