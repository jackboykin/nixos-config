{
  lib,
  pkgs,
  ...
}: let
  wanted = [
    "LTO_CLANG_THIN"
    "X86_NATIVE_CPU"
    "MODULE_COMPRESS_ZSTD"
  ];

  unwanted = [
    "MEM_ALLOC_PROFILING"
    "MODULE_COMPRESS_XZ"
    "RUST"
    "DRM_PANIC_SCREEN_QR_CODE"
    "NOVA_CORE"
    "DRM_NOVA"
  ];

  blacklisted = [
    "IP_SCTP"
    "RDS"
    "TIPC"
    "N_HDLC"
    "AF_RXRPC"
    "AFS_FS"
    "INET_ESP"
    "INET6_ESP"
    "X25"
    "ATM"
    "CAN"
    "IEEE802154"
    "CRAMFS"
    "JFFS2_FS"
    "HFS_FS"
    "HFSPLUS_FS"
    "HPFS_FS"
    "UDF_FS"
    "SMB_SERVER"
    "FIREWIRE"
    "USB4"
    "ATA"
    "CRYPTO_USER_API_AEAD"
    "CRYPTO_USER_API_HASH"
    "CRYPTO_USER_API_RNG"
    "CRYPTO_USER_API_SKCIPHER"
  ];

  absent = [
    "STAGING"
    "INFINIBAND"
    "IIO"
    "MEDIA_SUPPORT"
    "SND_SOC"
    "SCSI_LOWLEVEL"
    "WLAN"
    "BT"
    "NFC"
    "WWAN"
    "MTD"
    "PCCARD"
    "PARPORT"
    "CHROME_PLATFORMS"
    "SURFACE_PLATFORMS"
    "NET_DSA"
    "INPUT_TOUCHSCREEN"
    "DRM_I915"
    "DRM_XE"
    "DRM_NOUVEAU"
    "DRM_RADEON"
  ];

  kernel = pkgs.linux_testing.override {
    ignoreConfigErrors = true;
    stdenv = pkgs.llvmStdenv;
    structuredExtraConfig =
      lib.genAttrs wanted (_: lib.kernel.yes)
      // lib.genAttrs (unwanted ++ blacklisted ++ absent) (_: lib.mkForce (lib.kernel.option lib.kernel.no));
  };
in {
  boot.kernelPackages = pkgs.linuxPackagesFor kernel;
}
