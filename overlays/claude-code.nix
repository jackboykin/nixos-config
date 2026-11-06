pin: final: prev: let
  inherit (prev) lib;
in {
  claude-code = final.stdenvNoCC.mkDerivation {
    pname = "claude-code";
    inherit (pin) version;

    src = final.fetchurl {inherit (pin) url hash;};

    nativeBuildInputs = [final.autoPatchelfHook final.makeBinaryWrapper];

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/libexec/claude
      makeWrapper $out/libexec/claude $out/bin/claude \
        --argv0 claude \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [final.alsa-lib]} \
        --set DISABLE_AUTOUPDATER 1 \
        --set DISABLE_INSTALLATION_CHECKS 1
      runHook postInstall
    '';

    doInstallCheck = true;
    nativeInstallCheckInputs = [final.versionCheckHook];

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
