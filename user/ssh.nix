_: {
  programs.ssh.extraConfig = ''
    Host opnsense
      HostName 192.168.1.1
      User root

    Host greta
      HostName 192.168.1.161
      User greta

    Host opnsense greta
      ControlMaster auto
      ControlPath /run/user/%i/ssh-%C
      ControlPersist 2h
  '';
}
