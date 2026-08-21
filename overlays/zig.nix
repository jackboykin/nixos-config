pins: final: prev: let
  inherit (prev) lib;
in {
  zigpkgs = {
    master = prev.stdenvNoCC.mkDerivation {
      pname = "zig";
      inherit (pins.zig) version;
      src = prev.fetchurl {
        urls = let
          file = baseNameOf pins.zig.tarball;
        in [
          "https://pkg.hexops.org/zig/${file}"
          "https://zigmirror.hryx.net/zig/${file}"
          pins.zig.tarball
        ];
        sha256 = pins.zig.shasum;
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
        platforms = ["x86_64-linux"];
        mainProgram = "zig";
      };
    };

    zls = prev.stdenvNoCC.mkDerivation {
      pname = "zls";
      inherit (pins.zls) version;
      src = prev.fetchurl {
        url = pins.zls.tarball;
        sha256 = pins.zls.shasum;
      };
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
        platforms = ["x86_64-linux"];
        mainProgram = "zls";
      };
    };
  };
}
