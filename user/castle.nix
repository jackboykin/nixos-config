{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.castle) links dirs;
  inherit (config.users.users.jack) home;
  manifest = pkgs.writeText "castle-links" (lib.concatLines (lib.attrNames links));
in {
  options.castle = {
    links = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {};
    };

    dirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };

  config = {
    systemd.user.tmpfiles.users.jack.rules =
      lib.mapAttrsToList (path: src: "L+ ${home}/${path} - - - - ${src}") links
      ++ map (path: "d ${home}/${path} 0755 - - -") dirs;

    system.userActivationScripts.castle = ''
      if [ "$HOME" = ${home} ]; then
        state=$HOME/.local/state/castle/links
        if [ -f "$state" ]; then
          while IFS= read -r path; do
            if [[ $(readlink "$HOME/$path") == /nix/store/* ]]; then
              rm "$HOME/$path"
              rmdir -p --ignore-fail-on-non-empty "$(dirname "$HOME/$path")"
            fi
          done < <(grep -vxFf ${manifest} "$state" || true)
        fi
        install -Dm644 ${manifest} "$state"
      fi
    '';
  };
}
