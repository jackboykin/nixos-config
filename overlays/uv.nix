pin: final: _: {
  uv-release = final.stdenvNoCC.mkDerivation {
    pname = "uv";
    inherit (pin) version;

    src = final.fetchurl {inherit (pin) url hash;};

    installPhase = ''
      runHook preInstall
      install -Dm755 uv $out/bin/uv
      runHook postInstall
    '';

    meta.mainProgram = "uv";
  };
}
