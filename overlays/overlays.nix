inputs: [
  inputs.claude-code.overlays.default
  inputs.rust-overlay.overlays.default
  (import ./plasma-flatten.nix)
  (import ./zig.nix inputs.zig-index)
]
