pin: final: _: {
  bun = final.stdenvNoCC.mkDerivation {
    pname = "bun";
    inherit (pin) version;

    src = final.fetchurl {inherit (pin) url hash;};

    nativeBuildInputs = [final.unzip final.autoPatchelfHook];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 bun $out/bin/bun
      ln -s $out/bin/bun $out/bin/bunx
      runHook postInstall
    '';
  };
}
