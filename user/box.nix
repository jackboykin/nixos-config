{
  config,
  lib,
  pkgs,
  ...
}: let
  strings = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
  };
  nets = ["none" "own" "host"];

  closure = name: [config.box.${name}] ++ lib.concatMap closure config.box.${name}.use;

  launcher = name: box: let
    parts = closure name;
    all = attr: lib.unique (lib.concatMap (part: part.${attr}) parts);
    net = lib.last (lib.filter (net: lib.any (part: part.net == net) parts) nets);
    bus = all "bus";

    host = path:
      if lib.hasPrefix "/" path || lib.hasPrefix "$" path
      then path
      else "$HOME/${path}";
    quote = path: ''"${lib.replaceStrings ["*"] [''"*"''] path}"'';
    mount = flag: path: {
      path = host path;
      flag =
        if lib.hasPrefix "/dev/" path
        then "--dev-bind"
        else flag;
    };
    mounts = lib.sort (a: b: a.path < b.path) (
      map (mount "--ro-bind") (all "ro") ++ map (mount "--bind") (all "rw")
    );
  in
    pkgs.writeShellApplication {
      name = baseNameOf (lib.getExe box.package);
      runtimeInputs = with pkgs; [
        bubblewrap
        passt
        xdg-dbus-proxy
      ];
      text = ''
        args=()
        bind() {
          local flag=$1 path root
          shift
          for path; do
            root=''${path%/}
            case $HOME/ in
              "$root"/*)
                echo "box: $path holds too much to share" >&2
                exit 1
                ;;
            esac
            if [ -e "$path" ]; then
              args+=("$flag" "$path" "$path")
            fi
          done
        }

        for name in LANG LOCALE_ARCHIVE TERM TERMINFO_DIRS TZDIR XDG_CONFIG_DIRS XDG_DATA_DIRS ${toString (all "env")}; do
          if [ -n "''${!name-}" ]; then
            args+=(--setenv "$name" "''${!name}")
          fi
        done
        ${lib.concatMapStrings (path: ''
          mkdir -p ${quote (host path)}
        '') (lib.filter (path: host path != path) (all "rw"))}
        ${lib.concatMapStrings ({
            path,
            flag,
          }: ''
            bind ${flag} ${quote path}
          '')
          mounts}
        ${lib.optionalString (bus != []) ''
          mkdir -p "$XDG_RUNTIME_DIR/box"
          bus=$XDG_RUNTIME_DIR/box/${name}.$$
          exec {held}< <(exec xdg-dbus-proxy --fd=1 "$DBUS_SESSION_BUS_ADDRESS" "$bus" --filter ${lib.escapeShellArgs (map (rule: "--${rule}") bus)})
          read -r -N 1 -u "$held"
          trap 'rm "$bus"' EXIT
          args+=(--ro-bind "$bus" "$XDG_RUNTIME_DIR/bus" --setenv DBUS_SESSION_BUS_ADDRESS "unix:path=$XDG_RUNTIME_DIR/bus")
        ''}
        ${lib.optionalString (bus == []) "exec "}${lib.optionalString (net == "own") "pasta --config-net --quiet --no-map-gw -t none -u none -T none -U none -- "}bwrap \
          --unshare-all --unshare-user ${lib.optionalString (net != "none") "--share-net"} ${lib.optionalString (!lib.any (part: part.userns) parts) "--disable-userns"} --die-with-parent \
          --uid "$(id -u)" --gid "$(id -g)" \
          --clearenv \
          --setenv HOME "$HOME" --setenv USER "$USER" --setenv LOGNAME "$USER" \
          --setenv PATH "/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin" \
          --setenv XDG_RUNTIME_DIR "$XDG_RUNTIME_DIR" \
          --ro-bind /nix/store /nix/store \
          --ro-bind /etc /etc \
          --ro-bind /usr /usr \
          --ro-bind /bin /bin \
          --tmpfs /run \
          --ro-bind /run/current-system /run/current-system \
          --perms 0700 --dir "$XDG_RUNTIME_DIR" \
          --dev /dev \
          --proc /proc \
          --tmpfs /tmp \
          --tmpfs "$HOME" \
          "''${args[@]}" \
          -- ${lib.getExe box.package} "$@"
      '';
    };
in {
  options.box = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options =
        lib.genAttrs ["use" "ro" "rw" "env" "bus"] (_: strings)
        // {
          package = lib.mkOption {
            type = lib.types.nullOr lib.types.package;
            default = null;
          };

          net = lib.mkOption {
            type = lib.types.enum nets;
            default = "none";
          };

          userns = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
    });
    default = {};
  };

  config = {
    box = {
      wayland = {
        ro = ["$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"];
        env = ["WAYLAND_DISPLAY" "XCURSOR_PATH" "XDG_ACTIVATION_TOKEN" "XDG_SESSION_TYPE"];
      };

      gtk = {
        ro = [".config/dconf" ".config/gtk-3.0" ".config/gtk-4.0"];
        env = ["GDK_PIXBUF_MODULE_FILE" "GIO_EXTRA_MODULES" "GTK_PATH"];
      };

      gpu.ro = ["/dev/dri" "/run/opengl-driver" "/sys/dev/char" "/sys/devices"];
      audio.ro = ["$XDG_RUNTIME_DIR/pipewire-0" "$XDG_RUNTIME_DIR/pulse"];
      fido.ro = ["/dev/hidraw*" "/sys/class/hidraw" "/sys/devices"];
      castle.ro = lib.attrNames config.castle.links;

      jail = {
        package = pkgs.writeShellScriptBin "jail" ''exec "''${@:-$SHELL}"'';
        use = ["castle"];
        ro = ["$PWD/.git" "/nix/var/nix"];
        rw = ["$PWD"];
        env = ["COLORTERM" "EDITOR" "PAGER" "SHELL" "VISUAL"];
        net = "own";
      };
    };

    users.users.jack.packages =
      lib.concatLists (lib.mapAttrsToList (name: box: [(lib.hiPrio (launcher name box)) box.package])
        (lib.filterAttrs (_: box: box.package != null) config.box));
  };
}
