pin: final: prev: let
  inherit (prev) lib;
  inherit (pin) version;

  root = "LLVM-${version}-Linux-X64";
  shipped = [
    "bin/clang"
    "bin/clang++"
    "bin/clang-cpp"
    "bin/clang-${lib.versions.major version}"
    "bin/clangd"
    "bin/clang-format"
    "bin/clang-tidy"
    "bin/lld"
    "bin/llvm-addr2line"
    "bin/llvm-ar"
    "bin/llvm-cxxfilt"
    "bin/llvm-dwp"
    "bin/llvm-nm"
    "bin/llvm-objcopy"
    "bin/llvm-objdump"
    "bin/llvm-profdata"
    "bin/llvm-ranlib"
    "bin/llvm-readelf"
    "bin/llvm-readobj"
    "bin/llvm-size"
    "bin/llvm-strings"
    "bin/llvm-strip"
    "bin/llvm-symbolizer"
    "lib/clang"
  ];
  gnu = {
    addr2line = "llvm-symbolizer";
    ar = "llvm-ar";
    "c++filt" = "llvm-cxxfilt";
    dwp = "llvm-dwp";
    ld = "lld";
    "ld.lld" = "lld";
    nm = "llvm-nm";
    objcopy = "llvm-objcopy";
    objdump = "llvm-objdump";
    ranlib = "llvm-ar";
    readelf = "llvm-readobj";
    size = "llvm-size";
    strings = "llvm-strings";
    strip = "llvm-objcopy";
  };

  llvm = final.stdenvNoCC.mkDerivation {
    pname = "llvm";
    inherit version;
    src = final.fetchurl {inherit (pin) url hash;};

    nativeBuildInputs = [final.autoPatchelfHook final.zstd];
    buildInputs = [final.stdenv.cc.cc.lib final.zlib];

    unpackPhase = ''
      zstd -dc --long=31 $src | tar x ${lib.escapeShellArgs (map (p: "${root}/${p}") shipped)}
    '';

    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      mkdir $out
      cp -a ${root}/bin ${root}/lib $out
      runHook postInstall
    '';

    passthru = {
      isClang = true;
      langC = true;
      langCC = true;
      inherit (final.llvmPackages_latest.clang-unwrapped) hardeningUnsupportedFlagsByTargetPlatform;
    };

    meta.mainProgram = "clang";
  };

  binutils = final.runCommand "llvm-binutils-${version}" {passthru.isLLVM = true;} ''
    mkdir -p $out/bin
    ${lib.concatLines (lib.mapAttrsToList (name: tool: "ln -s ${llvm}/bin/${tool} $out/bin/${name}") gnu)}
  '';

  clang = final.wrapCCWith {
    cc = llvm;
    bintools = final.wrapBintoolsWith {bintools = binutils;};
  };

  tools = final.runCommand "clang-tools-${version}" {nativeBuildInputs = [final.makeBinaryWrapper];} ''
    dirs() {
      local d=
      while (($#)); do
        case $1 in -isystem | -cxx-isystem | -idirafter) d+=''${d:+:}$2; shift ;; esac
        shift
      done
      echo $d
    }
    c=$(dirs $(< ${clang}/nix-support/libc-cflags))
    cxx=$(dirs $(< ${clang}/nix-support/libcxx-cxxflags) $(< ${clang}/nix-support/libc-cflags))
    mkdir -p $out/bin
    for tool in clangd clang-tidy; do
      makeWrapper ${llvm}/bin/$tool $out/bin/$tool --suffix C_INCLUDE_PATH : $c --suffix CPLUS_INCLUDE_PATH : $cxx
    done
    ln -s ${llvm}/bin/clang-format $out/bin/clang-format
  '';
in {
  clang-release = clang;
  clang-tools-release = tools;
  llvmStdenv = final.overrideCC final.stdenv clang;
}
