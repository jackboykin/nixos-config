_: {
  boot = {
    kernelParams = [
      "slab_nomerge"
      "vsyscall=none"
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
      systemd = {
        enable = true;
        tpm2.enable = false;
      };
    };
    tmp.cleanOnBoot = true;
  };

  system = {
    nixos-init.enable = true;
    etc.overlay.enable = true;
  };

  security.protectKernelImage = true;
  systemd.tpm2.enable = false;
  services.lvm.enable = false;
}
