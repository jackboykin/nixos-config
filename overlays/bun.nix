pin: final: prev: {
  bun = prev.stdenvNoCC.mkDerivation {
    pname = "bun";
    inherit (pin) version;

    src =
      prev.runCommand "bun-layer.tar.gz" {
        nativeBuildInputs = [prev.curl];
        outputHash = prev.lib.removePrefix "sha256:" pin.layer;
        outputHashAlgo = "sha256";
        outputHashMode = "flat";
        SSL_CERT_FILE = "${prev.cacert}/etc/ssl/certs/ca-bundle.crt";
      } ''
        token=$(curl -s 'https://auth.docker.io/token?service=registry.docker.io&scope=repository:oven/bun:pull' | sed -E 's/.*"token":"([^"]+)".*/\1/')
        curl -sSfL -H "Authorization: Bearer $token" -o $out \
          "https://registry-1.docker.io/v2/oven/bun/blobs/${pin.layer}"
      '';

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [prev.autoPatchelfHook];
    buildInputs = [prev.openssl];

    installPhase = ''
      runHook preInstall
      tar -xzf $src usr/local/bin/bun
      install -Dm755 usr/local/bin/bun $out/bin/bun
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
