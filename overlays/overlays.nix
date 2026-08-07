inputs: [
  inputs.rust-overlay.overlays.default
  (import ./bun.nix inputs.bun-bin)
  (import ./claude-code.nix inputs.claude-code)
  (import ./ffmpeg.nix inputs.ffmpeg-master)
  (import ./firefox-nightly.nix inputs)
  (import ./qtweb.nix)
  (import ./plasma-flatten.nix)
  (import ./zig.nix inputs.zig-index)
]
