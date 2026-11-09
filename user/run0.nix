{pkgs, ...}: {
  users.users.jack.packages = [pkgs.run0-tty];

  security = {
    sudo.enable = false;
    run0.enable = true;
    wrappers = {
      su.enable = false;
      sg.enable = false;
      newgrp.enable = false;
    };
  };

  environment.sessionVariables.SYSTEMD_TINT_BACKGROUND = "0";
}
