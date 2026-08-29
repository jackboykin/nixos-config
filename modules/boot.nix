{
  pkgs,
  lib,
  ...
}: let
  disabledModules = [
    "dccp"
    "sctp"
    "rds"
    "tipc"
    "n_hdlc"
    "rxrpc"
    "esp4"
    "esp6"
    "ax25"
    "netrom"
    "rose"
    "x25"
    "atm"
    "can"
    "appletalk"
    "ieee802154"
    "cramfs"
    "freevxfs"
    "jffs2"
    "hfs"
    "hfsplus"
    "hpfs"
    "udf"
    "ksmbd"
    "firewire_core"
    "firewire_ohci"
    "firewire_sbp2"
    "firewire_net"
    "thunderbolt"
    "thunderbolt_net"
    "ahci"
    "vivid"
    "af_alg"
    "algif_aead"
    "algif_hash"
    "algif_rng"
    "algif_skcipher"
  ];
in {
  boot = {
    kernelPackages = pkgs.linuxPackages_testing;
    kernelParams = [
      "slab_nomerge"
      "randomize_kstack_offset=on"
      "vsyscall=none"
      "page_alloc.shuffle=1"
      "SYSTEMD_DEFAULT_MOUNT_RATE_LIMIT_BURST=50"
    ];
    tmp.cleanOnBoot = true;

    loader.timeout = 0;
    loader.efi.canTouchEfiVariables = true;

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    extraModprobeConfig = lib.concatMapStringsSep "\n" (m: "install ${m} ${pkgs.pkgsStatic.uutils-coreutils-noprefix}/bin/false") disabledModules;

    initrd.systemd.enable = true;
    initrd.systemd.tpm2.enable = false;
  };

  security.protectKernelImage = true;

  systemd.tpm2.enable = false;

  system.nixos-init.enable = true;
  system.etc.overlay.enable = true;
  services.lvm.enable = false;
}
