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

    firefox-nightly = {
      url = "file+https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US";
      flake = false;
    };

    firefox-versions = {
      url = "file+https://product-details.mozilla.org/1.0/firefox_versions.json";
      flake = false;
    };

    ffmpeg-master = {
      url = "github:FFmpeg/FFmpeg";
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
