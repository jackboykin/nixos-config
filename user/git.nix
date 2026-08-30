{
  pkgs,
  theme,
  lib,
  ...
}: let
  inherit (theme) colors;
  d = theme.diff;

  delta = lib.getExe pkgs.delta;

  settings = {
    user = {
      name = "Jack Boykin";
      email = "jtboykin.jb@gmail.com";
      signingKey = "~/.ssh/id_ed25519.pub";
    };
    init.defaultBranch = "master";
    pull.rebase = true;
    push.autoSetupRemote = true;
    rerere.enabled = true;
    commit.verbose = true;
    tag.gpgSign = true;
    merge.conflictStyle = "zdiff3";
    diff.algorithm = "histogram";
    diff.colorMoved = "default";

    credential = let
      helper = "!gh auth git-credential";
    in {
      "https://github.com".helper = helper;
      "https://gist.github.com".helper = helper;
    };

    gpg = {
      format = "ssh";
      ssh.program = lib.getExe' pkgs.openssh "ssh-keygen";
    };

    core.pager = delta;
    interactive.diffFilter = "${delta} --color-only";

    delta = {
      line-numbers = true;
      syntax-theme = "ansi";
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
      minus-emph-style = "bold syntax ${d.minusEmph}";
      minus-style = "syntax ${d.minus}";
      plus-emph-style = "bold syntax ${d.plusEmph}";
      plus-style = "syntax ${d.plus}";
      map-styles = lib.concatStringsSep "," [
        "bold purple => bold syntax ${d.maroon}"
        "bold blue => bold syntax ${d.blue}"
        "bold cyan => bold syntax ${d.cyan}"
        "bold yellow => bold syntax ${d.yellow}"
      ];
    };
  };
in {
  programs.git = {
    enable = true;
    lfs.enable = true;
    config = settings;
  };

  users.users.jack.packages = [pkgs.delta];
}
