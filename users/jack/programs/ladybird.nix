{pkgs, ...}: let
  src = pkgs.fetchFromGitHub {
    owner = "LadybirdBrowser";
    repo = "ladybird";
    rev = "ca97f68cb7869d2bda4d21add4f2d895d0e3c41a";
    hash = "sha256-OX7nCjLuejHcQGx4bdAMg3xfmM+KUBHsu93/Ym9KhRw=";
  };
in {
  home.packages = [
    (pkgs.ladybird.overrideAttrs (_finalAttrs: prev: {
      version = "0-unstable-2026-05-24";
      inherit src;
      cargoDeps = pkgs.rustPlatform.importCargoLock {
        lockFile = "${src}/Cargo.lock";
      };
      postPatch =
        prev.postPatch
        + ''
          substituteInPlace Meta/CMake/check_for_dependencies.cmake \
            --replace-fail "find_package(ICU 78.2 EXACT" "find_package(ICU ${pkgs.icu78.version} EXACT"
        '';
    }))
  ];
}
