{
  pkgs,
  lib,
  theme,
  ...
}: let
  profile = "jack";

  fontPrefs = {
    "font.default.x-western" = "sans-serif";
    "font.name.serif.x-western" = "Source Serif 4";
    "font.name.sans-serif.x-western" = theme.fonts.sans.name;
    "font.name.monospace.x-western" = theme.fonts.mono.name;
  };
in {
  users.users.jack.packages = [pkgs.firefox-nightly];

  castle.links = {
    ".config/mozilla/firefox/profiles.ini" = pkgs.writeText "profiles.ini" ''
      [General]
      StartWithLastProfile=1
      Version=2

      [Profile0]
      Default=1
      IsRelative=1
      Name=${profile}
      Path=${profile}
    '';

    ".config/mozilla/firefox/${profile}/user.js" =
      pkgs.writeText "user.js"
      (builtins.readFile ./firefox-prefs.js
        + "\n"
        + lib.concatLines (lib.mapAttrsToList
          (k: v: "user_pref(${builtins.toJSON k}, ${builtins.toJSON v});")
          fontPrefs));
  };
}
