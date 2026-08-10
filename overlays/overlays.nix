inputs: let
  pins = builtins.fromJSON (builtins.readFile ./pins.json);
in [
  inputs.rust-overlay.overlays.default
  (import ./bun.nix pins.bun)
  (import ./claude-code.nix pins."claude-code")
  (import ./ffmpeg.nix inputs.ffmpeg)
  (import ./firefox-nightly.nix pins.firefox)
  (import ./qtweb.nix)
  (import ./plasma-flatten.nix)
  (import ./zig.nix pins.zig)
]
