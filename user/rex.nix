{
  config,
  lib,
  pkgs,
  ...
}: {
  users.users.jack.packages = [pkgs.rex];

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [7297];

  programs.ssh.extraConfig = "Include ${pkgs.rex}/share/rex/ssh_config.d/50-rex.conf";

  systemd.user.services.rex = {
    description = "Rex server";
    wantedBy = ["default.target"];
    enableDefaultPath = false;
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.rex} server run --extra-listen tailnet://:7297";
      Restart = "on-failure";
    };
  };

  nix.settings.netrc-file = config.sops.templates.rex-netrc.path;

  sops = {
    secrets.rex = {};
    templates.rex-netrc = {
      content = "machine pkgs.superlogical.com login rex password ${config.sops.placeholder.rex}\n";
      owner = "jack";
    };
  };
}
