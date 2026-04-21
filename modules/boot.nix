{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = ["amd_pstate=active"];
    tmp.cleanOnBoot = true;

    loader.efi.canTouchEfiVariables = true;

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    blacklistedKernelModules = [
      "dccp"
      "sctp"
      "rds"
      "tipc"
      "n-hdlc"
      "can"
      "cramfs"
      "jffs2"
      "vivid"
    ];

    initrd.systemd.enable = true;
  };

  security.protectKernelImage = true;

  system.nixos-init.enable = true;
  system.etc.overlay.enable = true;
  services.userborn.enable = true;
}
