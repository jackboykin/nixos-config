{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nix-output-monitor
    sbctl
    sops
    age

    pkgsStatic.uutils-coreutils-noprefix
  ];

  environment.defaultPackages = [];

  programs.nano.enable = false;
  documentation = {
    info.enable = false;
    man.man-db.enable = false;
    man.mandoc.enable = true;
    nixos.enable = false;
  };
  system.tools.nixos-option.enable = false;
}
