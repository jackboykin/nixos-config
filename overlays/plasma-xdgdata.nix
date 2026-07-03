final: prev: {
  kdePackages = prev.kdePackages.overrideScope (kdeFinal: kdePrev: {
    plasma-workspace = let
      basePkg = kdePrev.plasma-workspace;
      xdgdata = final.stdenv.mkDerivation {
        name = "${basePkg.name}-xdgdata";
        buildInputs = [basePkg];
        dontUnpack = true;
        dontFixup = true;
        dontWrapQtApps = true;
        installPhase = ''
          mkdir -p $out/share
          ( IFS=:
            for dir in $XDG_DATA_DIRS; do
              [ -d "$dir" ] && ${final.lib.getExe final.lndir} -silent "$dir" $out/share
            done
          )
        '';
      };
    in
      basePkg.overrideAttrs {
        preFixup = ''
          for i in "''${!qtWrapperArgs[@]}"; do
            if [[ ''${qtWrapperArgs[$i]} == "--prefix" ]] && [[ ''${qtWrapperArgs[$((i + 1))]} == "XDG_DATA_DIRS" ]]; then
              unset -v "qtWrapperArgs[$i]" "qtWrapperArgs[$((i + 1))]" "qtWrapperArgs[$((i + 2))]" "qtWrapperArgs[$((i + 3))]"
            fi
          done
          qtWrapperArgs=("''${qtWrapperArgs[@]}")
          qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdata}/share")
          qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
        '';
      };
  });
}
