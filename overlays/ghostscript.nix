# 10.08.0 fixes CVE-2026-39919 (JPX heap overflow) and the zfproc/gsshade chain in
# github.com/v12-security/pocs, public command execution on 10.00.0-10.07.1 via PS/EPS/PDF.
# Dolphin thumbnails through gs, so a file merely landing in a viewed folder is enough.
# Scoped to gs's two consumers here to dodge a mass rebuild. Delete once nixpkgs has 10.08.0.
final: prev: let
  ghostscript = assert prev.lib.assertMsg (prev.ghostscript.version == "10.07.1") "ghostscript bumped, delete overlays/ghostscript.nix";
    prev.ghostscript.overrideAttrs {
      version = "10.08.0";
      src = prev.fetchurl {
        url = "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs10080/ghostscript-10.08.0.tar.xz";
        hash = "sha256-wgSSvI67lsh/ouUqCSbhzajN6V1mFF4BiscT/tXaOM8=";
      };
    };
in {
  libspectre = prev.libspectre.override {inherit ghostscript;};
  kdePackages = prev.kdePackages.overrideScope (_: kprev: {
    kdegraphics-thumbnailers = kprev.kdegraphics-thumbnailers.override {inherit ghostscript;};
  });
}
