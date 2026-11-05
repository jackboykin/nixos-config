{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (import ../theme.nix) colors;

  msmtp = lib.getExe pkgs.msmtp;

  settings = {
    user = {
      name = "Jack Boykin";
      email = "jtboykin.jb@gmail.com";
      signingKey = "~/.ssh/id_ed25519_sk_sign.pub";
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

    sendemail = {
      sendmailCmd = msmtp;
      confirm = "always";
      annotate = true;
    };

    gpg = {
      format = "ssh";
      ssh.program = lib.getExe' pkgs.openssh "ssh-keygen";
    };

    pager.diff = "${lib.getExe pkgs.hunk} pager";
    color.diff = {
      new = colors.gitAdded;
      old = colors.gitDeleted;
    };
  };
in {
  users.users.jack.packages = [pkgs.b4 pkgs.msmtp];

  programs.git = {
    enable = true;
    config = settings;
  };

  castle.links.".config/msmtp/config" = config.sops.templates.msmtp.path;

  sops = {
    secrets = {
      fastmail = {};
      fastmail-smtp = {};
    };
    templates.msmtp = {
      owner = "jack";
      content = ''
        account fastmail
        host smtp.fastmail.com
        tls on
        tls_starttls off
        auth on
        from ${config.sops.placeholder.fastmail}
        user ${config.sops.placeholder.fastmail}
        password ${config.sops.placeholder.fastmail-smtp}
      '';
    };
  };
}
