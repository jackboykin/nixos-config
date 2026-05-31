zig-index: final: prev: let
  inherit (prev) lib;
  index = builtins.fromJSON (builtins.readFile "${zig-index}");
  system = prev.stdenv.hostPlatform.system;

  mkZig = name: entry: let
    bin = entry.${system};
  in
    prev.stdenvNoCC.mkDerivation {
      pname = "zig";
      version = entry.version or name;
      src = prev.fetchurl {
        url = bin.tarball;
        sha256 = bin.shasum;
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
        platforms = lib.platforms.unix;
        mainProgram = "zig";
      };
    };
in {
  zigpkgs = lib.mapAttrs mkZig (lib.filterAttrs (_: v: builtins.hasAttr system v) index);
}
