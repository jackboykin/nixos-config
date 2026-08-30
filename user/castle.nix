{
  config,
  lib,
  ...
}: let
  inherit (config.users.users.jack) home;
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

  config.systemd.user.tmpfiles.users.jack.rules =
    lib.mapAttrsToList (path: src: "L+ ${home}/${path} - - - - ${src}") config.castle.links
    ++ map (path: "d ${home}/${path} 0755 - - -") config.castle.dirs;
}
