final: prev: {
  kdePackages = prev.kdePackages.overrideScope (kdeFinal: kdePrev: {
    plasma-workspace = kdePrev.plasma-workspace.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [final.lndir];
      preFixup =
        (old.preFixup or "")
        + ''
          flatVars="XDG_DATA_DIRS XDG_CONFIG_DIRS QT_PLUGIN_PATH NIXPKGS_QT6_QML_IMPORT_PATH"
          keptArgs=()
          ownArgs=()
          declare -A merged
          i=0
          while ((i < ''${#qtWrapperArgs[@]})); do
            if [[ ''${qtWrapperArgs[i]} == --prefix && " $flatVars " == *" ''${qtWrapperArgs[i + 1]} "* ]]; then
              var=''${qtWrapperArgs[i + 1]}
              dir=''${qtWrapperArgs[i + 3]}
              if [[ $dir == "$out"/* ]]; then
                ownArgs+=(--prefix "$var" : "$dir")
              else
                merged[$var]="$dir"$'\n'"''${merged[$var]-}"
              fi
              ((i += 4))
            else
              keptArgs+=("''${qtWrapperArgs[i]}")
              ((i += 1))
            fi
          done
          qtWrapperArgs=("''${keptArgs[@]}")
          for var in $flatVars; do
            [[ -n ''${merged[$var]-} ]] || continue
            flat=$out/flattened/$var
            mkdir -p "$flat"
            while read -r dir; do
              if [[ -d $dir ]]; then
                lndir -silent "$dir" "$flat" || true
              fi
            done <<<"''${merged[$var]}"
            qtWrapperArgs+=(--prefix "$var" : "$flat")
          done
          qtWrapperArgs+=("''${ownArgs[@]}")
        '';
    });
  });
}
