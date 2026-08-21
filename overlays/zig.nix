pins: final: prev: let
  inherit (prev) lib;
in {
  zigpkgs = {
    master = prev.stdenvNoCC.mkDerivation {
      pname = "zig";
      inherit (pins.zig) version;
      src = prev.fetchurl {
        urls = let
          file = baseNameOf pins.zig.url;
        in [
          "https://pkg.hexops.org/zig/${file}"
          "https://zigmirror.hryx.net/zig/${file}"
          pins.zig.url
        ];
        inherit (pins.zig) hash;
      };
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp -r lib $out/lib
        install -m755 zig $out/bin/zig
        runHook postInstall
      '';
      meta = {
        homepage = "https://ziglang.org";
        description = "General-purpose programming language and toolchain";
        license = lib.licenses.mit;
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        platforms = ["x86_64-linux"];
        mainProgram = "zig";
      };
    };

    zls = prev.stdenvNoCC.mkDerivation {
      pname = "zls";
      inherit (pins.zls) version;
      src = prev.fetchurl {inherit (pins.zls) url hash;};
      sourceRoot = ".";
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;
      installPhase = ''
        runHook preInstall
        install -Dm755 zls $out/bin/zls
        runHook postInstall
      '';
      meta = {
        homepage = "https://zigtools.org";
        description = "Language server for Zig";
        license = lib.licenses.mit;
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        platforms = ["x86_64-linux"];
        mainProgram = "zls";
      };
    };
  };
}
