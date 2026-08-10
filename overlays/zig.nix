pin: final: prev: let
  inherit (prev) lib;
in {
  zigpkgs.master = prev.stdenvNoCC.mkDerivation {
    pname = "zig";
    inherit (pin) version;
    src = prev.fetchurl {
      urls = let
        file = baseNameOf pin.tarball;
      in [
        "https://pkg.hexops.org/zig/${file}"
        "https://zigmirror.hryx.net/zig/${file}"
        pin.tarball
      ];
      sha256 = pin.shasum;
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
}
