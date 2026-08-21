pin: final: prev: {
  bun = prev.stdenvNoCC.mkDerivation {
    pname = "bun";
    inherit (pin) version;

    src = prev.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${pin.version}/bun-linux-x64.zip";
      sha256 = pin.shasum;
    };

    strictDeps = true;
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
      license = prev.lib.licenses.mit;
      platforms = ["x86_64-linux"];
      mainProgram = "bun";
    };
  };
}
