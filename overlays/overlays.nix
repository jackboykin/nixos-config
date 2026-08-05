inputs: [
  inputs.claude-code.overlays.default
  inputs.rust-overlay.overlays.default
  (import ./bun.nix inputs.bun-bin)
  (import ./ffmpeg.nix inputs.ffmpeg-master)
  (import ./firefox-nightly.nix inputs)
  (import ./plasma-flatten.nix)
  (import ./zig.nix inputs.zig-index)
]
