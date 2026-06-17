bun-manifest: final: prev: let
  inherit (prev) lib;
  manifest = builtins.fromJSON (builtins.readFile "${bun-manifest}");
in {
  bun-canary = prev.stdenvNoCC.mkDerivation {
    pname = "bun";
    inherit (manifest) version;

    src = prev.fetchurl {
      url = manifest.dist.tarball;
      hash = manifest.dist.integrity;
    };

    sourceRoot = "package";

    nativeBuildInputs = [prev.autoPatchelfHook];
    buildInputs = [prev.openssl];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 ./bin/bun $out/bin/bun
      ln -s $out/bin/bun $out/bin/bunx
      runHook postInstall
    '';

    meta = {
      homepage = "https://bun.sh";
      description = "Incredibly fast JavaScript runtime, bundler, test runner and package manager (canary)";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux"];
      mainProgram = "bun";
    };
  };
}
