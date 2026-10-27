{
  lib,
  pkgs,
  ...
}: let
  vesktop = pkgs.symlinkJoin {
    name = "vesktop";
    paths = [pkgs.vesktop];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/vesktop \
        --add-flags --enable-features=LimitLayerMergeDistance:limit/10 \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [pkgs.libva]}
    '';
  };
in {
  users.users.jack.packages = [vesktop];
}
