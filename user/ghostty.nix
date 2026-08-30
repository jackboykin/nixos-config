{
  lib,
  pkgs,
  theme,
  ...
}: let
  inherit (theme) colors fonts ui;

  toGhostty = settings:
    lib.concatStringsSep "\n" (lib.flatten (lib.mapAttrsToList
      (k: v: map (x: "${k} = ${toString x}") (lib.toList v))
      settings))
    + "\n";
in {
  users.users.jack.packages = [pkgs.ghostty];

  systemd.packages = [pkgs.ghostty];

  castle.links.".config/ghostty" = pkgs.linkFarm "ghostty-config" {
    "config" = pkgs.writeText "ghostty-config-file" (toGhostty {
      theme = "bellatrix";
      font-family = [fonts.mono.name fonts.mono.fallback];
      font-size = fonts.size.normal;
      freetype-load-flags = "no-light,no-autohint";
      window-decoration = "none";
      window-width = 143;
      window-height = 41;
    });

    "themes/bellatrix" = pkgs.writeText "ghostty-bellatrix" (toGhostty {
      palette = map (i: "${toString i}=${colors."color${toString i}"}") (lib.range 0 15);
      inherit (colors) background foreground;
      cursor-color = ui.cursor;
      selection-background = ui.selection;
    });
  };
}
