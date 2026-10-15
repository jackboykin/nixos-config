{pkgs, ...}: let
  vesktop = pkgs.symlinkJoin {
    name = "vesktop";
    paths = [pkgs.vesktop];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/vesktop --add-flags --enable-features=LimitLayerMergeDistance:limit/10
    '';
  };
in {
  users.users.jack.packages = [vesktop];
}
