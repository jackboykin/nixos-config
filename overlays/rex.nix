src: final: prev: let
  inherit (prev) lib;
  sources = lib.importJSON "${src}/sources.json";
in {
  rex = prev.stdenvNoCC.mkDerivation {
    pname = "rex";
    inherit (sources) version;

    src = prev.fetchurl {inherit (sources.systems.x86_64-linux) url sha256;};
    sourceRoot = ".";

    nativeBuildInputs = [final.patchelf];

    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;
    dontPatchELF = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 rex $out/bin/rex
      patchelf --set-rpath ${lib.makeLibraryPath [final.glibc final.pam]} $out/bin/rex
      patchelf --set-interpreter ${prev.stdenv.cc.bintools.dynamicLinker} $out/bin/rex
      install -Dm644 ${src}/xterm-rex.bin $out/share/terminfo/x/xterm-rex
      install -Dm644 ${src}/50-rex.conf $out/share/rex/ssh_config.d/50-rex.conf
      runHook postInstall
    '';

    meta = {
      homepage = "https://superlogical.com";
      description = "The multiplexer for all work";
      license = lib.licenses.unfree;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = "rex";
    };
  };
}
