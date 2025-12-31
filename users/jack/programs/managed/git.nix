{
  theme,
  lib,
  ...
}:
let
  c = theme.colors;
  d = theme.diff;
in
{
  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      user.name = "Jack Boykin";
      user.email = "jtboykin.jb@gmail.com";

      init.defaultBranch = "master";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.autocrlf = "input";
      merge.conflictstyle = "diff3";
      diff.algorithm = "histogram";
      diff.colorMoved = "default";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      line-numbers = true;
      syntax-theme = "blackberry-aquamarine";
      blame-palette = lib.concatStringsSep " " [
        c.base
        c.mantle
        c.crust
        c.surface0
        c.surface1
      ];
      dark = true;
      file-decoration-style = c.text;
      file-style = c.text;
      hunk-header-decoration-style = d.hunkHeader;
      hunk-header-file-style = d.hunkHeader;
      hunk-header-line-number-style = d.hunkHeader;
      hunk-header-style = d.hunkHeader;
      line-numbers-left-style = c.overlay0;
      line-numbers-minus-style = "bold ${c.red}";
      line-numbers-plus-style = "bold ${c.green}";
      line-numbers-right-style = c.overlay0;
      line-numbers-zero-style = c.overlay0;
      minus-emph-style = "bold syntax bg:${d.minusEmph}";
      minus-style = "syntax bg:${d.minus}";
      plus-emph-style = "bold syntax bg:${d.plusEmph}";
      plus-style = "syntax bg:${d.plus}";
      map-styles = lib.concatStringsSep " " [
        "bold purple => bold syntax bg:${d.maroon}"
        "bold blue => bold syntax bg:${d.blue}"
        "bold cyan => bold syntax bg:${d.cyan}"
        "bold yellow => bold syntax bg:${d.yellow}"
      ];
    };
  };
}
