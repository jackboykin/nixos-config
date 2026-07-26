inputs: [
  inputs.claude-code.overlays.default
  inputs.rust-overlay.overlays.default
  (import ./firefox-ffmpeg.nix)
  (import ./plasma-flatten.nix)
  (import ./zig.nix inputs.zig-index)
]
