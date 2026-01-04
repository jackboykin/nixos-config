{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    nix-output-monitor
    sbctl
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${username}/nixos-config";
  };
}
