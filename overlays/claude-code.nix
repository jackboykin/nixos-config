claude-code: final: prev: let
  inherit (prev) lib;

  npm = builtins.fromJSON (builtins.readFile "${claude-code}");
in {
  claude-code = prev.stdenv.mkDerivation {
    pname = "claude-code";
    inherit (npm) version;

    src = prev.fetchurl {
      url = npm.dist.tarball;
      hash = npm.dist.integrity;
    };

    nativeBuildInputs = [prev.autoPatchelfHook prev.makeBinaryWrapper];

    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 claude $out/bin/claude
      runHook postInstall
    '';

    postFixup = ''
      wrapProgram $out/bin/claude \
        --argv0 claude \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [prev.alsa-lib]} \
        --set DISABLE_AUTOUPDATER 1 \
        --set DISABLE_INSTALLATION_CHECKS 1
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
