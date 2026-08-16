{
  pkgs,
  lib,
  username,
  ...
}: let
  settings = {
    user = {
      name = "Jack Boykin";
      email = "jtboykin.jb@gmail.com";
    };

    ui = {
      pager = lib.getExe pkgs.delta;
      diff-formatter = ":git";
      default-command = "log";
    };

    signing = {
      backend = "ssh";
      behavior = "own";
      key = "~/.ssh/id_ed25519.pub";
      backends.ssh.program = lib.getExe' pkgs.openssh "ssh-keygen";
    };
  };
in {
  home.links.".config/jj/config.toml" =
    (pkgs.formats.toml {}).generate "jj-config.toml" settings;

  users.users.${username}.packages = [pkgs.jujutsu];
}
