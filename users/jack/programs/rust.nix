{pkgs, ...}: let
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = ["rust-src" "rust-analyzer" "clippy"];
  };
in {
  home.packages = [rustToolchain];

  home.sessionVariables = {
    RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
  };
}
