{username, ...}: {
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${username}/nixos-config";
  };

  nix = {
    channel.enable = false;
    optimise.automatic = true;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "cgroups"
        "auto-allocate-uids"
      ];
      use-cgroups = true;
      auto-allocate-uids = true;
      allowed-users = [
        "root"
        "@wheel"
      ];
      flake-registry = "";
      use-xdg-base-directories = true;
      max-jobs = 2;
      cores = 16;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };
}
