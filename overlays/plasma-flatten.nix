final: prev: let
  inherit (final) lib;

  # Session roots first: they win forest collisions.
  members = [
    "plasma-workspace"
    "kwin"
    "dolphin"
    "kate"
    "konsole"
  ];

  flatVars = ["NIXPKGS_QT6_QML_IMPORT_PATH" "QT_PLUGIN_PATH" "XDG_CONFIG_DIRS" "XDG_DATA_DIRS"];
in {
  kdePackages = let
    kp = prev.kdePackages;

    shimOutputs = pkg: lib.intersectLists ["out" "sessions"] pkg.outputs;
    srcsOf = pkg: map (o: "${pkg.${o}}") (shimOutputs pkg);

    forest =
      final.runCommand "plasma-session-forest" {
        nativeBuildInputs = [final.binutils final.lndir final.shared-mime-info final.desktop-file-utils final.gtk3];
        srcPaths = lib.concatMap (n: srcsOf kp.${n}) members;
        flatVars = toString flatVars;
      } ''
        # Every search dir the vanilla wrappers prefix, highest priority first.
        # Each --prefix prepends, so a wrapper's last arg ends up first in the env.
        for src in $srcPaths; do
          find "$src" -type f -executable -print0 | while IFS= read -r -d "" f; do
            strings -dw "$f" | sed -n '/^makeCWrapper/,/^$/p' \
              | sed -n "s/^ *--prefix '\([A-Z0-9_]*\)' ':' '\([^']*\)'.*/\1 \2/p" | tac
          done
        done | awk -v vars=" $flatVars " 'index(vars, " " $1 " ") && !seen[$0]++' >manifest
        [[ -s manifest ]] || { echo "forest: no wrapper search dirs found" >&2; exit 1; }

        mkdir -p "$out"
        cp manifest "$out/MANIFEST"
        while read -r var dir; do
          if [[ -d $dir ]]; then
            mkdir -p "$out/$var"
            lndir -silent "$dir" "$out/$var" 2>>"$NIX_BUILD_TOP/collide.$var" || true
          fi
        done <manifest
        # lndir names each source dir once, then every file it kept the earlier link for.
        # Same content under two store paths is not a collision.
        touch "$out/COLLISIONS"
        for f in "$NIX_BUILD_TOP"/collide.*; do
          [[ -s $f ]] || continue
          var=''${f##*.}
          awk '
            /:$/ {d = substr($0, 1, length($0) - 1); next}
            /: Keeping existing link to / {split($0, a, ": Keeping existing link to "); print d "/" a[1], a[2]; next}
            {print "forest: unparsed lndir message: " $0 > "/dev/stderr"; exit 1}
          ' "$f" | while read -r new old; do
            cmp -s "$new" "$old" || echo "$var $new -> $old"
          done >>"$out/COLLISIONS"
        done
        if grep -v '^XDG_DATA_DIRS ' "$out/COLLISIONS" >&2; then
          echo "forest: conflicting files under an order-sensitive var" >&2
          exit 1
        fi
        # KPackage resolves files through canonical paths and rejects any outside the
        # canonical package root, so a package must be one symlink, not a tree of them.
        while read -r m; do
          root=''${m%/*}
          [[ $(realpath "$root") == "$out"/* ]] || continue
          src=$(readlink "$m")
          src=''${src%/*}
          if find "$root" -type l -exec readlink {} + | grep -v "^$src/" >&2; then
            echo "forest: KPackage $root is assembled from more than one store path" >&2
            exit 1
          fi
          rm -r "$root"
          ln -s "$src" "$root"
        done < <(find "$out/XDG_DATA_DIRS" -name metadata.json -o -name metadata.desktop)
        if find "$out/XDG_DATA_DIRS" -name metadata.json -o -name metadata.desktop | grep . >&2; then
          echo "forest: KPackage roots left as link trees" >&2
          exit 1
        fi
        if [[ -d $out/XDG_DATA_DIRS/mime/packages ]]; then
          find "$out/XDG_DATA_DIRS/mime" -mindepth 1 -maxdepth 1 ! -name packages -exec rm -r {} +
          update-mime-database "$out/XDG_DATA_DIRS/mime"
        fi
        if [[ -d $out/XDG_DATA_DIRS/applications ]]; then
          rm -f "$out/XDG_DATA_DIRS/applications/mimeinfo.cache"
          update-desktop-database "$out/XDG_DATA_DIRS/applications"
        fi
        for themedir in "$out"/XDG_DATA_DIRS/icons/*/; do
          [[ -d $themedir && ! -L ''${themedir%/} ]] || continue
          rm -f "$themedir/icon-theme.cache"
          gtk-update-icon-cache --ignore-theme-index --quiet "$themedir"
        done
      '';

    shims = lib.genAttrs members (n: shim kp.${n});

    shim = pkg:
      final.runCommand pkg.name {
        outputs = shimOutputs pkg;
        srcPaths = srcsOf pkg;
        flatVars = toString flatVars;
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
            kept=()
            j=1
            while ((j < ''${#words[@]})); do
              if [[ ''${words[j]} == --prefix && " $flatVars " == *" ''${words[j + 1]} "* ]]; then
                ((j += 4))
              else
                kept+=("''${words[j]}")
                ((j += 1))
              fi
            done
            w=$dst''${f#"$src"}
            rm "$w"
            makeBinaryWrapper "$exe" "$w" "''${kept[@]}" "''${forestArgs[@]}"
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

        if [[ -L $out/nix-support ]]; then
          rm "$out/nix-support"
        fi
        mkdir -p "$out/nix-support"
        printf '%s\n' "''${srcs[@]}" >"$out/nix-support/shim-vanilla"
      '';
  in
    kp // shims;
}
