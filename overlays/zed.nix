pin: final: prev: let
  inherit (prev) lib;
in {
  zed-editor = final.stdenvNoCC.mkDerivation {
    pname = "zed-editor";
    inherit (pin) version;

    src = final.fetchurl {inherit (pin) url hash;};

    nativeBuildInputs = [final.autoPatchelfHook final.makeBinaryWrapper];
    buildInputs = with final; [stdenv.cc.cc.lib alsa-lib glib libxkbcommon libX11 libxcb];

    runtimeDependencies = [final.libGL final.vulkan-loader final.wayland];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir $out
      cp -r bin libexec share $out
      runHook postInstall
    '';

    postFixup = ''
      wrapProgram $out/libexec/zed-editor \
        --set ZED_UPDATE_EXPLANATION "Zed is managed by Nix." \
        --suffix PATH : ${lib.makeBinPath [final.nodejs]}
    '';

    meta = {
      homepage = "https://zed.dev";
      description = "High-performance, multiplayer code editor";
      license = lib.licenses.gpl3Only;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = "zed";
    };
  };
}
