pin: final: prev: let
  inherit (prev) lib;
in {
  zed-editor = prev.stdenvNoCC.mkDerivation {
    pname = "zed-editor";
    inherit (pin) version;

    src = prev.fetchurl {inherit (pin) url hash;};

    nativeBuildInputs = [prev.autoPatchelfHook prev.makeBinaryWrapper];
    buildInputs = with prev; [stdenv.cc.cc.lib alsa-lib glib libxkbcommon libX11 libxcb];

    runtimeDependencies = [prev.libGL prev.vulkan-loader prev.wayland];

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
        --suffix PATH : ${lib.makeBinPath [prev.nodejs]}
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
