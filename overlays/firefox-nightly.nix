pin: final: prev: let
  inherit (prev) lib;

  wrapperArgs = lib.functionArgs (import "${final.path}/pkgs/applications/networking/browsers/firefox/wrapper.nix");
  ffmpegs = lib.filter (name: builtins.match "ffmpeg(_[0-9]+)?" name != null) (lib.attrNames wrapperArgs);

  unwrapped =
    (final.firefox-bin-unwrapped.override {
      generated = {
        inherit (pin) version;
        sources = [];
      };
      applicationName = "Firefox Nightly";
    })
    .overrideAttrs {
      pname = "firefox-nightly-bin-unwrapped";
      src = final.fetchurl {inherit (pin) url hash;};
    };
in {
  firefox-nightly = assert ffmpegs != [];
    (final.wrapFirefox.override (lib.genAttrs ffmpegs (_: final.ffmpeg-release)))
    unwrapped {pname = "firefox-nightly-bin";};
}
