pin: final: _: {
  agy = final.stdenvNoCC.mkDerivation {
    pname = "agy";
    inherit (pin) version;

    src = final.fetchurl {inherit (pin) url hash;};

    sourceRoot = ".";

    nativeBuildInputs = [final.makeBinaryWrapper];

    installPhase = ''
      runHook preInstall
      install -Dm755 antigravity $out/libexec/agy
      makeBinaryWrapper $out/libexec/agy $out/bin/agy --set AGY_CLI_FORCE_FILE_TOKEN_STORAGE 1
      runHook postInstall
    '';

    doInstallCheck = true;
    nativeInstallCheckInputs = [final.versionCheckHook];

    meta.mainProgram = "agy";
  };
}
