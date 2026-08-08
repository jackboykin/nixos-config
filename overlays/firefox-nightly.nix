inputs: final: prev: let
  inherit (prev) lib;

  inherit (builtins.fromJSON (builtins.readFile "${inputs.firefox-index}")) taskId;
  version = (builtins.fromJSON (builtins.readFile "${inputs.firefox-buildhub}")).target.version;
  sha512 = lib.pipe (builtins.readFile "${inputs.firefox-checksums}") [
    (lib.splitString "\n")
    (map (builtins.match "([0-9a-f]{128}) sha512 [0-9]+ target\\.tar\\.xz"))
    (lib.findFirst (m: m != null) (throw "target.checksums lists no sha512 for target.tar.xz"))
    builtins.head
  ];

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
      src = prev.fetchurl {
        url = "https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/${taskId}/artifacts/public/build/target.tar.xz";
        inherit sha512;
      };
    };
in {
  firefox-nightly = assert lib.assertMsg (lib.versionAtLeast version "146") "firefox ${version} takes the ffmpeg_7 branch";
    (prev.wrapFirefox.override {ffmpeg_8 = final.ffmpeg-release;})
    unwrapped {pname = "firefox-nightly-bin";};
}
