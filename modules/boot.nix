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
    ];
    tmp.cleanOnBoot = true;

    loader.timeout = 1;
    loader.efi.canTouchEfiVariables = true;

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    blacklistedKernelModules = disabledModules;
    extraModprobeConfig = lib.concatMapStringsSep "\n" (m: "install ${m} ${pkgs.pkgsStatic.uutils-coreutils-noprefix}/bin/false") disabledModules;

    initrd.systemd.enable = true;
  };

  security.protectKernelImage = true;

  system.nixos-init.enable = true;
  system.etc.overlay.enable = true;
  services.userborn.enable = true;
}
