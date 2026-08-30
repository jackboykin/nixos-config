{
  pkgs,
  theme,
  ...
}: let
  inherit (theme) colors;
  fg = color: "38;2;${builtins.concatStringsSep ";" (theme.rgb color)}";
  ezaColorsStr = builtins.concatStringsSep ":" [
    "di=${fg colors.blue}"
    "ln=${fg colors.cyan}"
    "ex=${fg colors.green}"
    "or=${fg colors.red}"
    "su=${fg colors.red}"
    "sg=${fg colors.yellow}"
    "tw=${fg colors.green}"
    "ow=${fg colors.blue}"
    "pi=${fg colors.orange}"
    "so=${fg colors.magenta}"
    "bd=${fg colors.orange}"
    "cd=${fg colors.orange}"

    "ur=${fg colors.yellow}"
    "uw=${fg colors.red}"
    "ux=${fg colors.green}"
    "ue=${fg colors.green}"
    "gr=${fg colors.yellow}"
    "gw=${fg colors.red}"
    "gx=${fg colors.green}"
    "tr=${fg colors.yellow}"
    "tx=${fg colors.green}"

    "uu=${fg colors.cyan}"
    "uR=${fg colors.subtext0}"
    "gu=${fg colors.purple}"
    "gR=${fg colors.subtext0}"

    "sn=${fg colors.green}"
    "sb=${fg colors.green}"

    "da=${fg colors.subtext0}"

    "ga=${fg colors.gitAdded}"
    "gm=${fg colors.gitModified}"
    "gd=${fg colors.gitDeleted}"
    "gv=${fg colors.cyan}"
    "gt=${fg colors.subtext0}"

    "hd=4;${fg colors.text}"
  ];
in {
  users.users.jack.packages = [pkgs.eza];

  programs.nushell.autoloads = [
    (pkgs.writeTextDir "share/nushell/vendor/autoload/10-eza.nu" ''
      $env.EZA_COLORS = "${ezaColorsStr}"
    '')
  ];
}
