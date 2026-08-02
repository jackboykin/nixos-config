bun-bin: final: prev: {
  bun = prev.stdenvNoCC.mkDerivation {
    pname = "bun";
    version = "canary";

    src = bun-bin;
    unpackCmd = "${prev.unzip}/bin/unzip $curSrc";
    sourceRoot = "bun-linux-x64";

    nativeBuildInputs = [prev.autoPatchelfHook];
    buildInputs = [prev.openssl];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 ./bun $out/bin/bun
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
