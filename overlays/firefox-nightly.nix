inputs: final: prev: let
  inherit (prev) lib;

  version = (builtins.fromJSON (builtins.readFile "${inputs.firefox-versions}")).FIREFOX_NIGHTLY;

  unwrapped =
    (prev.firefox-bin-unwrapped.override {
      generated = {
        inherit version;
        sources = [];
      };
      applicationName = "Firefox Nightly";
    })
    .overrideAttrs {
      pname = "firefox-nightly-bin-unwrapped";
      src = inputs.firefox-nightly;
      unpackCmd = "tar xf $curSrc";
    };
in {
  firefox-nightly = assert lib.assertMsg (lib.versionAtLeast version "146") "firefox ${version} takes the ffmpeg_7 branch";
    (prev.wrapFirefox.override {ffmpeg_8 = final.ffmpeg-master;})
    unwrapped {pname = "firefox-nightly-bin";};
}
