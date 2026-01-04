_: {
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];

    # optimize store
    auto-optimise-store = true;

    # parallelism
    max-jobs = "auto";
    # cores (0=all)
    cores = 0;

    # binary caches
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    # remote builder substitutes
    builders-use-substitutes = true;
  };

  nixpkgs.config.allowUnfree = true;
}
