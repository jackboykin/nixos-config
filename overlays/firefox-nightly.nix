pin: final: prev: let
  inherit (prev) lib;

  unwrapped =
    (prev.firefox-bin-unwrapped.override {
      generated = {
        inherit (pin) version;
        sources = [];
      };
      applicationName = "Firefox Nightly";
    })
    .overrideAttrs {
      pname = "firefox-nightly-bin-unwrapped";
      src = prev.fetchurl {inherit (pin) url sha512;};
    };
in {
  firefox-nightly = assert lib.assertMsg (lib.versionAtLeast pin.version "146") "firefox ${pin.version} takes the ffmpeg_7 branch";
    (prev.wrapFirefox.override {ffmpeg_8 = final.ffmpeg-release;})
    unwrapped {pname = "firefox-nightly-bin";};
}
