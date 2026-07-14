{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nix-output-monitor
    sbctl
    sops
    age
  ];
}
