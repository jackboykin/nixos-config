pin: final: _: let
  # github.com/NixOS/nixpkgs/pull/588093; drop once merged
  patchelf = final.patchelfUnstable.overrideAttrs {
    version = "0.19.3";
    src = final.fetchFromGitHub {
      owner = "NixOS";
      repo = "patchelf";
      tag = "0.19.3";
      hash = "sha256-jeHuH5wi8yEs148ApY636xkVhp4jT5tRZHTluW4AQtY=";
    };
  };
in {
  claude-code = final.stdenvNoCC.mkDerivation {
    pname = "claude-code";
    inherit (pin) version;

    src = final.fetchurl {inherit (pin) url hash;};

    nativeBuildInputs = [final.autoPatchelfHook patchelf final.makeBinaryWrapper];

    runtimeDependencies = [final.alsa-lib];
    patchelfFlags = ["--force-rpath"];

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/libexec/claude
      makeWrapper $out/libexec/claude $out/bin/claude \
        --argv0 claude \
        --set DISABLE_UPDATES 1 \
        --set DISABLE_INSTALLATION_CHECKS 1
      runHook postInstall
    '';

    doInstallCheck = true;
    nativeInstallCheckInputs = [final.versionCheckHook];

    meta.mainProgram = "claude";
  };
}
