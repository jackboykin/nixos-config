_: {
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
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://ryoppippi.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms="
      ];
      use-xdg-base-directories = true;
      max-jobs = 2;
      cores = 16;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = ["pnpm-10.29.2"];
  };
}
