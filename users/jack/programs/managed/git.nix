{
  theme,
  lib,
  ...
}: let
  c = theme.colors;
  d = theme.diff;
in {
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
      syntax-theme = "edo";
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
      minus-emph-style = "bold syntax ${d.minusEmph}";
      minus-style = "syntax ${d.minus}";
      plus-emph-style = "bold syntax ${d.plusEmph}";
      plus-style = "syntax ${d.plus}";
      map-styles = lib.concatStringsSep " " [
        "bold purple => syntax ${d.purple}"
        "bold blue => syntax ${d.blue}"
        "bold cyan => syntax ${d.cyan}"
        "bold yellow => syntax ${d.yellow}"
      ];
    };
  };
}
