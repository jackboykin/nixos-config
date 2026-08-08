{
  description = "Modular NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig-index = {
      url = "file+https://ziglang.org/download/index.json";
      flake = false;
    };

    bun-bin = {
      url = "file+https://github.com/oven-sh/bun/releases/download/canary/bun-linux-x64.zip";
      flake = false;
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
        pre-commit.follows = "";
      };
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "file+https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/latest";
      flake = false;
    };

    firefox-index = {
      url = "file+https://firefox-ci-tc.services.mozilla.com/api/index/v1/task/gecko.v2.mozilla-central.shippable.latest.firefox.linux64-opt";
      flake = false;
    };

    firefox-checksums = {
      url = "file+https://firefox-ci-tc.services.mozilla.com/api/index/v1/task/gecko.v2.mozilla-central.shippable.latest.firefox.linux64-opt/artifacts/public/build/target.checksums";
      flake = false;
    };

    firefox-buildhub = {
      url = "file+https://firefox-ci-tc.services.mozilla.com/api/index/v1/task/gecko.v2.mozilla-central.shippable.latest.firefox.linux64-opt/artifacts/public/build/buildhub.json";
      flake = false;
    };

    ffmpeg = {
      url = "github:FFmpeg/FFmpeg/release/9.0";
      flake = false;
    };

    ffmpeg-index = {
      url = "file+https://ffmpeg.org/releases/";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    lanzaboote,
    sops-nix,
    ...
  }: let
    system = "x86_64-linux";
    inherit (nixpkgs) lib;
    theme = import ./lib/theme.nix {inherit lib;};

    lock = lib.importJSON ./flake.lock;
    fileInputs =
      lib.mapAttrsToList (name: _: inputs.${name})
      (lib.filterAttrs (_: node: lock.nodes.${node}.locked.type == "file")
        lock.nodes.${lock.root}.inputs);

    overlays = import ./overlays/overlays.nix inputs;

    mkHost = {
      hostname,
      username,
    }:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit username hostname theme;};
        modules = [
          ./hosts/${hostname}/host.nix
          ./modules/modules.nix
          ./users/${username}/user.nix
          {
            nixpkgs.hostPlatform = lib.mkDefault system;
            nixpkgs.overlays = overlays;
            system.extraDependencies = fileInputs;
          }
          lanzaboote.nixosModules.lanzaboote
          sops-nix.nixosModules.sops
        ];
      };
  in {
    nixosConfigurations.nixos-orion = mkHost {
      hostname = "nixos-orion";
      username = "jack";
    };

    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
