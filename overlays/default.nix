inputs: let
  pins = builtins.fromJSON (builtins.readFile ./pins.json);
in [
  inputs.rust-overlay.overlays.default
  inputs.quarry.overlays.default
  inputs.run0-tty.overlays.default
  (import ./agy.nix pins.agy)
  (import ./bun.nix pins.bun)
  (import ./claude-code.nix pins.claude-code)
  (import ./ffmpeg.nix inputs.ffmpeg)
  (import ./firefox-nightly.nix pins.firefox)
  (import ./libplacebo.nix pins.libplacebo)
  (import ./linux.nix pins.linux)
  (import ./linux-firmware.nix pins.linux-firmware)
  (import ./llvm.nix pins.llvm)
  (import ./mesa.nix pins.mesa)
  (import ./mpv.nix pins.mpv)
  (import ./python.nix pins.python)
  (import ./rex.nix inputs.rex)
  (import ./uv.nix pins.uv)
  (import ./zed.nix pins.zed)
  (import ./zig.nix {inherit (pins) zig zig-nightly zls;})
]
