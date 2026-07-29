{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nix-output-monitor
    sbctl
    sops
    age
  ];

  environment.defaultPackages = [];

  programs.nano.enable = false;
  documentation.info.enable = false;
}
