final: prev: let
  inherit (final) lib;

  members = [
    "dolphin"
    "kate"
    "konsole"
    "kwin"
    "plasma-workspace"
  ];

  subdirs = {
    NIXPKGS_QT6_QML_IMPORT_PATH = "lib/qt-6/qml";
    QT_PLUGIN_PATH = "lib/qt-6/plugins";
    XDG_CONFIG_DIRS = "etc/xdg";
    XDG_DATA_DIRS = "share";
  };
in {
  kdePackages = let
    kp = prev.kdePackages;

    step = d:
      map (x: {
        key = x.outPath;
        val = x;
      }) (lib.filter (x: lib.isDerivation x && !(lib.elem (lib.getName x) members)) d);

    closureOf = inputs:
      map (x: x.val) (builtins.genericClosure {
        startSet = step inputs;
        operator = item:
          step ((item.val.propagatedBuildInputs or []) ++ (item.val.propagatedNativeBuildInputs or []));
      });

    manifestOf = pkg: let
      deps = closureOf ((pkg.buildInputs or []) ++ (pkg.propagatedBuildInputs or []));
    in
      lib.flatten (lib.mapAttrsToList (
          var: sub:
            map (d: ["${var} ${d.bin or d.out or d}/${sub}" "${var} ${d.out or d}/${sub}"]) deps
        )
        subdirs);

    manifest =
      lib.concatLines (lib.unique (lib.concatMap (n: manifestOf kp.${n}) members));

    forest =
      final.runCommand "plasma-session-forest" {
        nativeBuildInputs = [final.lndir final.shared-mime-info final.desktop-file-utils final.gtk3];
        inherit manifest;
        passAsFile = ["manifest"];
      } ''
        while read -r var dir; do
          if [[ -d $dir ]]; then
            mkdir -p "$out/$var"
            lndir -silent "$dir" "$out/$var" 2>>"$NIX_BUILD_TOP/collide.$var" || true
          fi
        done <"$manifestPath"
        touch "$out/COLLISIONS"
        for f in "$NIX_BUILD_TOP"/collide.*; do
          [[ -s $f ]] || continue
          var=''${f##*.}
          if [[ $var != XDG_DATA_DIRS ]]; then
            echo "forest: link collisions under order-sensitive $var:" >&2
            cat "$f" >&2
            exit 1
          fi
          sed "s|^|$var |" "$f" >>"$out/COLLISIONS"
        done
        sort -u -o "$out/COLLISIONS" "$out/COLLISIONS"
        if [[ -d $out/XDG_DATA_DIRS/mime/packages ]]; then
          find "$out/XDG_DATA_DIRS/mime" -mindepth 1 -maxdepth 1 ! -name packages -exec rm -r {} +
          update-mime-database "$out/XDG_DATA_DIRS/mime"
        fi
        if [[ -d $out/XDG_DATA_DIRS/applications ]]; then
          rm -f "$out/XDG_DATA_DIRS/applications/mimeinfo.cache"
          update-desktop-database "$out/XDG_DATA_DIRS/applications"
        fi
        for themedir in "$out"/XDG_DATA_DIRS/icons/*/; do
          [[ -d $themedir ]] || continue
          rm -f "$themedir/icon-theme.cache"
          gtk-update-icon-cache --ignore-theme-index --quiet "$themedir"
        done
      '';

    shimOutputs = pkg: lib.intersectLists ["out" "sessions"] pkg.outputs;

    shims = lib.genAttrs members (n: shim kp.${n});

    # lndir over substituted vanilla, kept alive as a real reference. Only two
    # things diverge: wrappers rebuilt with dep dirs collapsed into the forest,
    # and exec-surface text (units, dbus, .desktop) repointed at the shim.
    shim = pkg:
      final.runCommand pkg.name {
        outputs = shimOutputs pkg;
        srcPaths = map (o: "${pkg.${o}}") (shimOutputs pkg);
        flattenManifest = manifest;
        passAsFile = ["flattenManifest"];
        flatVars = toString (lib.attrNames subdirs);
        nativeBuildInputs = [final.lndir final.makeBinaryWrapper final.binutils];
        preferLocalBuild = true;
        allowSubstitutes = false;
        passthru =
          (pkg.passthru or {})
          // lib.genAttrs (lib.subtractLists (shimOutputs pkg) pkg.outputs) (o: pkg.${o})
          // {vanilla = pkg;};
        meta =
          pkg.meta
          // {
            outputsToInstall = lib.intersectLists (shimOutputs pkg) (pkg.meta.outputsToInstall or ["out"]);
          };
      } ''
        outs=($outputs)
        srcs=($srcPaths)

        sedExpr=
        grepArgs=()
        # exec surfaces only -- a share ref repointed at the shim's symlink
        # forest risks the KPackage canonicalize-outside-root rejection
        for i in "''${!outs[@]}"; do
          for d in bin libexec; do
            sedExpr+="s|''${srcs[i]}/$d|''${!outs[i]}/$d|g;"
            grepArgs+=(-e "''${srcs[i]}/$d")
          done
        done
        forestArgs=()
        for var in $flatVars; do
          if [[ -d ${forest}/$var ]]; then
            forestArgs+=(--prefix "$var" : "${forest}/$var")
          fi
        done

        rewrapped=0
        droppedData=0
        for i in "''${!outs[@]}"; do
          src=''${srcs[i]}
          dst=''${!outs[i]}
          mkdir -p "$dst"
          lndir -silent "$src" "$dst"

          while IFS= read -r -d "" f; do
            cmd=$(strings -dw "$f" | sed -n '/^makeCWrapper/,/^$/p')
            [[ -n $cmd ]] || continue
            eval "words=( ''${cmd#makeCWrapper} )"
            exe=''${words[0]}
            if [[ $exe != "$src"/* ]]; then
              echo "shim: wrapped executable $exe escaped $src" >&2
              exit 1
            fi
            args=("''${words[@]:1}")
            kept=()
            own=()
            fileFlat=0
            fileDropped=0
            j=0
            while ((j < ''${#args[@]})); do
              if [[ ''${args[j]} == --prefix && " $flatVars " == *" ''${args[j + 1]} "* ]]; then
                var=''${args[j + 1]}
                dir=''${args[j + 3]}
                if [[ $dir == "$src"/* ]]; then
                  own+=(--prefix "$var" : "$dir")
                else
                  fileFlat=$((fileFlat + 1))
                  if grep -qxF "$var $dir" "$flattenManifestPath"; then
                    fileDropped=$((fileDropped + 1))
                    if [[ $var == XDG_DATA_DIRS ]]; then
                      droppedData=$((droppedData + 1))
                    fi
                  else
                    kept+=(--prefix "$var" : "$dir")
                  fi
                fi
                ((j += 4))
              else
                kept+=("''${args[j]}")
                ((j += 1))
              fi
            done
            if ((fileFlat > 0 && fileDropped == 0)); then
              echo "shim: $f has dep-dir wrapper args but none matched the manifest; hook layout changed" >&2
              exit 1
            fi
            w=$dst''${f#"$src"}
            rm "$w"
            makeBinaryWrapper "$exe" "$w" "''${kept[@]}" "''${forestArgs[@]}" "''${own[@]}"
            rewrapped=$((rewrapped + 1))
          done < <(find "$src" -type f -executable -print0)

          while IFS= read -r f; do
            [[ -L $f ]] || continue
            t=$(readlink "$f")
            rm "$f"
            sed "$sedExpr" "$t" >"$f"
            chmod --reference="$t" "$f"
          done < <(grep -RlIF "''${grepArgs[@]}" "$dst")
        done

        if ((rewrapped == 0)); then
          echo "shim: found no binary wrappers to rebuild" >&2
          exit 1
        fi
        if ((droppedData == 0)); then
          echo "shim: dropped no XDG_DATA_DIRS wrapper args; hook layout changed" >&2
          exit 1
        fi

        # unreferenced after the sed; a GC'd vanilla output forces a source rebuild
        if [[ -L $out/nix-support ]]; then
          rm "$out/nix-support"
        fi
        mkdir -p "$out/nix-support"
        printf '%s\n' "''${srcs[@]}" >"$out/nix-support/shim-vanilla"
      '';
  in
    kp // shims;
}
