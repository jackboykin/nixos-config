{
  pkgs,
  lib,
  theme,
  ...
}: let
  inherit (theme) colors;

  palette = {
    "bg+" = colors.base;
    spinner = colors.purple;
    hl = colors.red;
    fg = colors.text;
    header = colors.red;
    info = colors.purple;
    pointer = colors.purple;
    marker = colors.blue;
    "fg+" = colors.text;
    prompt = colors.purple;
    "hl+" = colors.red;
    "selected-bg" = colors.surface1;
  };
  defaultOpts =
    "--multi --color "
    + lib.concatStringsSep "," (lib.mapAttrsToList (k: v: "${k}:${v}") palette);

  prelude = pkgs.writeText "fzf-env.nu" ''
    $env.FZF_DEFAULT_OPTS = "${defaultOpts}"
  '';
in {
  users.users.jack.packages = [pkgs.fzf];

  programs.nushell.autoloads = [
    (pkgs.runCommand "fzf-nushell" {} ''
      mkdir -p $out/share/nushell/vendor/autoload
      out=$out/share/nushell/vendor/autoload/50-fzf.nu
      cat ${prelude} > $out
      ${lib.getExe pkgs.fzf} --nushell >> $out
    '')
  ];
}
