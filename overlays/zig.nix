pins: final: prev: let
  inherit (prev) lib;
  zig = pname: let
    pin = pins.${pname};
  in
    prev.stdenvNoCC.mkDerivation {
      inherit pname;
      inherit (pin) version;
      src = prev.fetchurl {
        urls = let
          file = baseNameOf pin.url;
        in [
          "https://pkg.hexops.org/zig/${file}"
          "https://zigmirror.hryx.net/zig/${file}"
          pin.url
        ];
        inherit (pin) hash;
      };
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp -r lib $out/lib
        install -m755 zig $out/bin/${pname}
        runHook postInstall
      '';
      meta = {
        homepage = "https://ziglang.org";
        description = "General-purpose programming language and toolchain";
        license = lib.licenses.mit;
        sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        platforms = ["x86_64-linux"];
        mainProgram = pname;
      };
    };
in {
  zigpkgs = {
    stable = zig "zig";
    nightly = zig "zig-nightly";

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
