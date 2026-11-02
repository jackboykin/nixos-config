{pkgs, ...}: let
  inherit (pkgs.linux_testing) version src modDirVersion;
  stdenv = pkgs.llvmStdenv;

  configfile = stdenv.mkDerivation {
    pname = "linux-config";
    inherit version src;
    nativeBuildInputs = with pkgs; [
      bison
      flex
      openssl
      pahole
    ];
    hardeningDisable = ["all"];
    dontConfigure = true;
    buildPhase = ''
      patchShebangs scripts
      cp ${./kernel.config} .config
      make LLVM=1 KCONFIG_WARN_UNKNOWN_SYMBOLS=1 KCONFIG_WERROR=1 olddefconfig
    '';
    installPhase = "cp .config $out";
    dontFixup = true;
  };

  kernel = pkgs.linuxManualConfig {
    inherit version src modDirVersion stdenv configfile;
    kernelPatches = with pkgs.kernelPatches; [
      bridge_stp_helper
      request_key_helper
    ];
    config = {
      CONFIG_MODULES = "y";
      CONFIG_FW_LOADER = "y";
      CONFIG_RUST = "n";
    };
  };
in {
  boot.kernelPackages = pkgs.linuxPackagesFor kernel;
}
