{
  lib,
  pkgs,
  theme,
  ...
}: let
  inherit (theme) colors diff;

  delta = lib.getExe pkgs.delta;
  msmtp = lib.getExe pkgs.msmtp;

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

    sendemail = {
      sendmailCmd = msmtp;
      confirm = "always";
      annotate = true;
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
      hunk-header-decoration-style = "'${diff.hunkHeader}'";
      hunk-header-file-style = "'${diff.hunkHeader}'";
      hunk-header-line-number-style = "'${diff.hunkHeader}'";
      hunk-header-style = "'${diff.hunkHeader}'";
      line-numbers-left-style = "'${colors.overlay0}'";
      line-numbers-minus-style = "bold '${colors.red}'";
      line-numbers-plus-style = "bold '${colors.green}'";
      line-numbers-right-style = "'${colors.overlay0}'";
      line-numbers-zero-style = "'${colors.overlay0}'";
      minus-emph-style = "bold syntax ${diff.minusEmph}";
      minus-style = "syntax ${diff.minus}";
      plus-emph-style = "bold syntax ${diff.plusEmph}";
      plus-style = "syntax ${diff.plus}";
      map-styles = lib.concatStringsSep "," [
        "bold purple => bold syntax ${diff.maroon}"
        "bold blue => bold syntax ${diff.blue}"
        "bold cyan => bold syntax ${diff.cyan}"
        "bold yellow => bold syntax ${diff.yellow}"
      ];
    };
  };
in {
  users.users.jack.packages = [pkgs.delta pkgs.msmtp];

  programs.git = {
    enable = true;
    lfs.enable = true;
    config = settings;
  };

  castle.links.".config/msmtp/config" = pkgs.writeText "msmtp-config" ''
    account default
    host smtp.gmail.com
    tls on
    tls_starttls off
    auth on
    from ${settings.user.email}
    user ${settings.user.email}
  '';
}
