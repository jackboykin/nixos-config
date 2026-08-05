{
  pkgs,
  lib,
  theme,
  username,
  ...
}: let
  inherit (theme) colors;

  palette = {
    fg = colors.text;
    bg = colors.base;
    black = colors.color0;
    inherit (colors) red green yellow blue magenta cyan white orange;
  };
in {
  users.users.${username}.packages = [pkgs.zellij];

  home.links.".config/zellij" = pkgs.writeTextDir "config.kdl" ''
    pane_frames false
    show_release_notes false
    show_startup_tips false
    theme "custom"
    themes {
        custom {
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "        ${k} \"${v}\"") palette)}
        }
    }
  '';
}
