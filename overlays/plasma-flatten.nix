final: prev: let
  inherit (final) lib;

  subdirs = {
    NIXPKGS_QT6_QML_IMPORT_PATH = "lib/qt-6/qml";
    QT_PLUGIN_PATH = "lib/qt-6/plugins";
    XDG_CONFIG_DIRS = "etc/xdg";
    XDG_DATA_DIRS = "share";
  };

  flattenQtPaths = pkg: let
    deps =
      lib.filter lib.isDerivation
      (lib.closePropagation ((pkg.buildInputs or []) ++ (pkg.propagatedBuildInputs or [])));

    manifest =
      lib.concatLines (lib.unique (lib.flatten
          (lib.mapAttrsToList (var: sub: map (d: "${var} ${d.bin or d.out or d}/${sub}") deps) subdirs)));

    forest =
      final.runCommand "${pkg.name}-flattened" {
        nativeBuildInputs = [final.lndir final.shared-mime-info final.desktop-file-utils];
        inherit manifest;
        passAsFile = ["manifest"];
      } ''
        while read -r var dir; do
          if [[ -d $dir ]]; then
            mkdir -p "$out/$var"
            lndir -silent "$dir" "$out/$var" || true
          fi
        done <"$manifestPath"
        if [[ -d $out/XDG_DATA_DIRS/mime/packages ]]; then
          find "$out/XDG_DATA_DIRS/mime" -mindepth 1 -maxdepth 1 ! -name packages -exec rm -r {} +
          update-mime-database "$out/XDG_DATA_DIRS/mime"
        fi
        if [[ -d $out/XDG_DATA_DIRS/applications ]]; then
          rm -f "$out/XDG_DATA_DIRS/applications/mimeinfo.cache"
          update-desktop-database "$out/XDG_DATA_DIRS/applications"
        fi
        rm -f "$out"/XDG_DATA_DIRS/icons/*/icon-theme.cache
      '';
  in
    pkg.overrideAttrs (old: {
      flattenManifest = manifest;
      passAsFile = (old.passAsFile or []) ++ ["flattenManifest"];
      preFixup =
        (old.preFixup or "")
        + ''
          flatVars="${toString (lib.attrNames subdirs)}"
          keptArgs=()
          ownArgs=()
          sawData=
          i=0
          while ((i < ''${#qtWrapperArgs[@]})); do
            if [[ ''${qtWrapperArgs[i]} == --prefix && " $flatVars " == *" ''${qtWrapperArgs[i + 1]} "* ]]; then
              var=''${qtWrapperArgs[i + 1]}
              dir=''${qtWrapperArgs[i + 3]}
              if [[ $dir == "$out"/* ]]; then
                ownArgs+=(--prefix "$var" : "$dir")
              elif grep -qxF "$var $dir" "$flattenManifestPath"; then
                if [[ $var == XDG_DATA_DIRS ]]; then
                  sawData=1
                fi
              else
                keptArgs+=(--prefix "$var" : "$dir")
              fi
              ((i += 4))
            else
              keptArgs+=("''${qtWrapperArgs[i]}")
              ((i += 1))
            fi
          done
          [[ -n $sawData ]] || {
            echo "flattenQtPaths: parsed no XDG_DATA_DIRS wrapper args; hook layout changed" >&2
            exit 1
          }
          qtWrapperArgs=("''${keptArgs[@]}")
          for var in $flatVars; do
            if [[ -d ${forest}/$var ]]; then
              qtWrapperArgs+=(--prefix "$var" : "${forest}/$var")
            fi
          done
          qtWrapperArgs+=("''${ownArgs[@]}")
        '';
    });
in {
  kdePackages = prev.kdePackages.overrideScope (kdeFinal: kdePrev: {
    plasma-workspace = flattenQtPaths kdePrev.plasma-workspace;
  });
}
