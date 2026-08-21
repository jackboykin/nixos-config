pin: final: prev: let
  inherit (prev) lib;
in {
  bun = prev.stdenvNoCC.mkDerivation {
    pname = "bun";
    inherit (pin) version;

    src = prev.fetchurl {inherit (pin) url hash;};

    nativeBuildInputs = [prev.unzip prev.autoPatchelfHook];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 bun $out/bin/bun
      ln -s $out/bin/bun $out/bin/bunx
      runHook postInstall
    '';

    meta = {
      homepage = "https://bun.sh";
      description = "Incredibly fast JavaScript runtime, bundler, test runner and package manager";
      license = lib.licenses.mit;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = "bun";
    };
  };
}
