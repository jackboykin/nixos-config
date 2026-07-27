final: prev: let
  inherit (final) lib;

  members = [
    "dolphin"
    "kate"
    "konsole"
    "kwin"
    "plasma-workspace"
  ];

  # copy-wrapped for member-path rewriting only; contribute nothing to the forest
  rewrites = ["plasma-login-manager"];

  subdirs = {
    NIXPKGS_QT6_QML_IMPORT_PATH = "lib/qt-6/qml";
    QT_PLUGIN_PATH = "lib/qt-6/plugins";
    XDG_CONFIG_DIRS = "etc/xdg";
    XDG_DATA_DIRS = "share";
  };
in {
  kdePackages = let
    kp = prev.kdePackages;

    step = withMembers: d:
      map (x: {
        key = x.outPath;
        val = x;
      }) (lib.filter (x: lib.isDerivation x && (withMembers || !(lib.elem (lib.getName x) members))) d);

    closureOf = withMembers: inputs:
      map (x: x.val) (builtins.genericClosure {
        startSet = step withMembers inputs;
        operator = item:
          step withMembers ((item.val.propagatedBuildInputs or []) ++ (item.val.propagatedNativeBuildInputs or []));
      });

    inputsOf = pkg: (pkg.buildInputs or []) ++ (pkg.propagatedBuildInputs or []);

    manifestOf = pkg: let
      deps = closureOf false (inputsOf pkg);
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

    copiedOutputs = pkg: lib.intersectLists ["out" "sessions"] pkg.outputs;

    memberDepsOf = pkg: let
      names = map lib.getName (closureOf true (inputsOf pkg));
    in
      lib.filter (m: m != lib.getName pkg && lib.elem m names) members;

    copies = lib.genAttrs (members ++ rewrites) (n: copyWrap kp.${n});

    # cp -a of the substituted upstream package, member store hashes rewritten
    # (same-length, replaceDependency-style), binary wrappers rebuilt from their
    # embedded makeCWrapper docstrings with flattened env args.
    copyWrap = pkg: let
      pairs =
        map (o: {
          old = "${pkg.${o}}";
          new = placeholder o;
        }) (copiedOutputs pkg)
        ++ lib.concatMap (
          m:
            map (o: {
              old = "${kp.${m}.${o}}";
              new = "${copies.${m}.${o}}";
            }) (copiedOutputs kp.${m})
        ) (memberDepsOf pkg);
    in
      final.runCommand pkg.name {
        outputs = copiedOutputs pkg;
        srcPaths = map (o: "${pkg.${o}}") (copiedOutputs pkg);
        replaceOld = map (p: p.old) pairs;
        replaceNew = map (p: p.new) pairs;
        forbidden =
          lib.concatMap (
            m:
              map (o: baseNameOf (builtins.unsafeDiscardStringContext "${kp.${m}.${o}}")) (copiedOutputs kp.${m})
          )
          (members ++ rewrites);
        flattenManifest = manifest;
        passAsFile = ["flattenManifest"];
        flatVars = toString (lib.attrNames subdirs);
        nativeBuildInputs = [final.makeBinaryWrapper final.binutils final.gtk3];
        preferLocalBuild = true;
        allowSubstitutes = false;
        passthru =
          (pkg.passthru or {})
          // lib.genAttrs (lib.subtractLists (copiedOutputs pkg) pkg.outputs) (o: pkg.${o})
          // {vanilla = pkg;};
        meta =
          pkg.meta
          // {
            outputsToInstall = lib.intersectLists (copiedOutputs pkg) (pkg.meta.outputsToInstall or ["out"]);
          };
      } ''
        outs=($outputs)
        srcs=($srcPaths)
        olds=($replaceOld)
        news=($replaceNew)

        sedscript="$NIX_BUILD_TOP/rewrite.sed"
        touch "$sedscript"
        for i in "''${!olds[@]}"; do
          old=''${olds[i]}
          new=''${news[i]}
          if ((''${#old} != ''${#new})); then
            echo "copyWrap: length mismatch: $old -> $new" >&2
            exit 1
          fi
          lhs=$(printf '%s' "$old" | sed 's/[.[\*^$]/\\&/g')
          rhs=''${new//\\/\\\\}
          rhs=''${rhs//&/\\&}
          printf 's|%s|%s|g\n' "$lhs" "$rhs" >>"$sedscript"
        done

        for i in "''${!outs[@]}"; do
          dst=''${!outs[i]}
          cp -a "''${srcs[i]}" "$dst"
          chmod -R u+w "$dst"
          find "$dst" -type f -print0 | xargs -0 -r sed -i -f "$sedscript"
          while IFS= read -r -d "" l; do
            t=$(readlink "$l")
            nt=$t
            for j in "''${!olds[@]}"; do
              nt=''${nt//''${olds[j]}/''${news[j]}}
            done
            if [[ $nt != "$t" ]]; then
              ln -sfT "$nt" "$l"
            fi
          done < <(find "$dst" -type l -print0)
        done

        rewrapped=0
        droppedData=0
        while IFS= read -r -d "" f; do
          cmd=$(strings -dw "$f" | sed -n '/^makeCWrapper/,/^$/p')
          [[ -n $cmd ]] || continue
          eval "words=( ''${cmd#makeCWrapper} )"
          exe=''${words[0]}
          if [[ $exe != "$out"/* ]]; then
            echo "copyWrap: wrapped executable $exe escaped $out" >&2
            exit 1
          fi
          args=("''${words[@]:1}")
          kept=()
          own=()
          fileFlat=0
          fileDropped=0
          i=0
          while ((i < ''${#args[@]})); do
            if [[ ''${args[i]} == --prefix && " $flatVars " == *" ''${args[i + 1]} "* ]]; then
              var=''${args[i + 1]}
              dir=''${args[i + 3]}
              if [[ $dir == "$out"/* ]]; then
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
              ((i += 4))
            else
              kept+=("''${args[i]}")
              ((i += 1))
            fi
          done
          forestArgs=()
          for var in $flatVars; do
            if [[ -d ${forest}/$var ]]; then
              forestArgs+=(--prefix "$var" : "${forest}/$var")
            fi
          done
          if ((fileFlat > 0 && fileDropped == 0)); then
            echo "copyWrap: $f has dep-dir wrapper args but none matched the manifest; hook layout changed" >&2
            exit 1
          fi
          rm "$f"
          makeBinaryWrapper "$exe" "$f" "''${kept[@]}" "''${forestArgs[@]}" "''${own[@]}"
          rewrapped=$((rewrapped + 1))
        done < <(find "$out" -type f -executable -print0)

        if ((rewrapped == 0)); then
          echo "copyWrap: found no binary wrappers to rebuild" >&2
          exit 1
        fi
        if ((droppedData == 0)); then
          echo "copyWrap: dropped no XDG_DATA_DIRS wrapper args; hook layout changed" >&2
          exit 1
        fi

        for themedir in "$out"/share/icons/*/; do
          [[ -d $themedir ]] || continue
          rm -f "$themedir/icon-theme.cache"
          gtk-update-icon-cache --ignore-theme-index --quiet "$themedir"
        done

        for i in "''${!outs[@]}"; do
          dst=''${!outs[i]}
          for h in $forbidden; do
            if hits=$(grep -rlF "$h" "$dst"); then
              echo "copyWrap: vanilla member reference $h survives in:" >&2
              echo "$hits" >&2
              exit 1
            fi
            while IFS= read -r -d "" l; do
              if [[ $(readlink "$l") == *"$h"* ]]; then
                echo "copyWrap: vanilla member symlink $l -> $(readlink "$l")" >&2
                exit 1
              fi
            done < <(find "$dst" -type l -print0)
            while IFS= read -r -d "" z; do
              case $z in
                *.gz) dec="gzip -dc" ;;
                *.bz2) dec="bzip2 -dc" ;;
                *.xz) dec="xz -dc" ;;
              esac
              if $dec "$z" | grep -qF "$h"; then
                echo "copyWrap: vanilla member reference $h inside compressed $z" >&2
                exit 1
              fi
            done < <(find "$dst" \( -name '*.gz' -o -name '*.bz2' -o -name '*.xz' \) -type f -print0)
          done
        done
      '';
  in
    kp // copies;
}
