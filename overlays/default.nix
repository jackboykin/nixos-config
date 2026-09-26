inputs: let
  pins = builtins.fromJSON (builtins.readFile ./pins.json);
in [
  inputs.rust-overlay.overlays.default
  inputs.quarry.overlays.default
  (import ./bun.nix pins.bun)
  (import ./claude-code.nix pins.claude-code)
  (import ./ffmpeg.nix inputs.ffmpeg)
  (import ./ghostscript.nix)
  (import ./firefox-nightly.nix pins.firefox)
  (import ./linux.nix pins.linux)
  (import ./zed.nix pins.zed)
  (import ./zig.nix {inherit (pins) zig zls;})
]
