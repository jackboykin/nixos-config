{
  theme,
  lib,
  ...
}:
let
  colors = theme.colors;
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
      syntax-theme = "colors";
      blame-palette = lib.concatStringsSep " " (
        map (c: "'${c}'") [
          colors.base
          colors.mantle
          colors.crust
          colors.surface0
          colors.surface1
        ]
      );
      light = false;
      file-decoration-style = "'${colors.text}'";
      file-style = "'${colors.text}'";
      hunk-header-decoration-style = "'${d.hunkHeader}'";
      hunk-header-file-style = "'${d.hunkHeader}'";
      hunk-header-line-number-style = "'${d.hunkHeader}'";
      hunk-header-style = "'${d.hunkHeader}'";
      line-numbers-left-style = "'${colors.overlay0}'";
      line-numbers-minus-style = "bold '${colors.red}'";
      line-numbers-plus-style = "bold '${colors.green}'";
      line-numbers-right-style = "'${colors.overlay0}'";
      line-numbers-zero-style = "'${colors.overlay0}'";
      minus-emph-style = "bold syntax \"bg:${d.minusEmph}\"";
      minus-style = "syntax \"bg:${d.minus}\"";
      plus-emph-style = "bold syntax \"bg:${d.plusEmph}\"";
      plus-style = "syntax \"bg:${d.plus}\"";
      map-styles = lib.concatStringsSep " " [
        "\"bold purple => bold syntax bg:${d.maroon}\""
        "\"bold blue => bold syntax bg:${d.blue}\""
        "\"bold cyan => bold syntax bg:${d.cyan}\""
        "\"bold yellow => bold syntax bg:${d.yellow}\""
      ];
    };
  };
}
