pin: final: prev: let
  inherit (prev) lib;

  shipped = prev.stdenvNoCC.mkDerivation {
    pname = "claude-code-shipped";
    inherit (pin) version;

    src = prev.fetchurl {inherit (pin) url hash;};

    nativeBuildInputs = [prev.autoPatchelfHook final.binutils-unwrapped];

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/claude
      objcopy --remove-section .bun $src bun
      install -Dm755 bun $out/libexec/bun
      runHook postInstall
    '';
  };
in {
  claude-code = prev.stdenvNoCC.mkDerivation {
    pname = "claude-code";
    inherit (pin) version;

    nativeBuildInputs = [prev.makeBinaryWrapper];

    dontUnpack = true;
    dontConfigure = true;
    dontStrip = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      OUT=$PWD/src BUN_OPTIONS="--preload ${./extract.js}" ${shipped}/bin/claude --version
      BASE=${shipped}/bin/claude ${shipped}/libexec/bun ${./build.ts} $PWD/src $PWD/cli
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 cli $out/libexec/claude
      makeWrapper $out/libexec/claude $out/bin/claude \
        --argv0 claude \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [prev.alsa-lib]} \
        --set DISABLE_AUTOUPDATER 1 \
        --set DISABLE_INSTALLATION_CHECKS 1
      runHook postInstall
    '';

    doInstallCheck = true;
    nativeInstallCheckInputs = [prev.versionCheckHook];

    meta = {
      homepage = "https://claude.ai/code";
      description = "Agentic coding tool that lives in your terminal";
      license = lib.licenses.unfree;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = "claude";
    };
  };
}
