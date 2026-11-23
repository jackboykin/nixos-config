pin: final: _: {
  python-release = final.stdenvNoCC.mkDerivation {
    pname = "python";
    inherit (pin) version;

    src = final.fetchurl {inherit (pin) url hash;};

    nativeBuildInputs = [final.autoPatchelfHook];
    buildInputs = [final.stdenv.cc.cc.lib];

    installPhase = ''
      runHook preInstall
      rm bin/idle* bin/pip*
      cp -r . $out
      runHook postInstall
    '';

    meta.mainProgram = "python3";
  };
}
