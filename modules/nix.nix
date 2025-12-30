{...}: {
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
    # Hard-link duplicate files in the store to save space
    auto-optimise-store = true;

    # Build parallelism: auto = number of CPUs
    max-jobs = "auto";
    # Cores per build job: 0 = use all available cores
    cores = 0;

    # Binary caches - download pre-built packages instead of compiling
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    # Let remote builders use these caches too
    builders-use-substitutes = true;
  };

  nixpkgs.config.allowUnfree = true;
}
