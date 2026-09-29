{config, ...}: {
  sops.secrets.opnsense-ssh.owner = "jack";

  programs.ssh.extraConfig = ''
    Host opnsense
      HostName 192.168.1.1
      User root
      IdentityFile ${config.sops.secrets.opnsense-ssh.path}
      IdentitiesOnly yes
  '';
}
