pin: final: _: let
  inherit (pin) version;
  src = (final.fetchzip {inherit (pin) url hash;}).overrideAttrs {outputHashMode = "git";};
  stdenv = final.llvmStdenv;

  configfile = stdenv.mkDerivation {
    pname = "linux-config";
    inherit version src;
    nativeBuildInputs = with final; [
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
      if grep '^CONFIG_' ${./kernel.config} | grep -Fvxf .config; then
        echo "kernel.config: Kconfig dropped the lines above" >&2
        exit 1
      fi
    '';
    installPhase = "cp .config $out";
    dontFixup = true;
  };
in {
  linux-orion = final.linuxManualConfig {
    inherit version src stdenv configfile;
    kernelPatches = with final.kernelPatches; [
      bridge_stp_helper
      request_key_helper
    ];
    config = {
      CONFIG_MODULES = "y";
      CONFIG_FW_LOADER = "y";
      CONFIG_RUST = "n";
    };
  };
}
