pin: final: _: {
  agy = final.stdenvNoCC.mkDerivation {
    pname = "agy";
    inherit (pin) version;

    src = final.fetchurl {inherit (pin) url hash;};

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm755 antigravity $out/bin/agy
      runHook postInstall
    '';

    doInstallCheck = true;
    nativeInstallCheckInputs = [final.versionCheckHook];

    meta.mainProgram = "agy";
  };
}
