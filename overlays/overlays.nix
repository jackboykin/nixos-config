inputs: [
  inputs.claude-code.overlays.default
  inputs.rust-overlay.overlays.default
  (import ./zig.nix inputs.zig-index)
  (import ./bun.nix inputs.bun-bin)
]
