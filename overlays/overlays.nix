inputs: [
  inputs.claude-code.overlays.default
  inputs.rust-overlay.overlays.default
  (import ./bun.nix inputs.bun-bin)
  (import ./firefox-ffmpeg.nix)
  (import ./plasma-flatten.nix)
  (import ./zig.nix inputs.zig-index)
]
