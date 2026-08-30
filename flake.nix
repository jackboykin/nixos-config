{
  description = "Modular NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
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

    ffmpeg = {
      url = "github:FFmpeg/FFmpeg/release/9.0";
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
    theme = import ./theme.nix {inherit lib;};

    inputSources = let
      node = i: {
        key = i.outPath;
        children = lib.attrValues (i.inputs or {});
      };
    in
      lib.remove self.outPath (map (n: n.key) (builtins.genericClosure {
        startSet = map node (lib.attrValues inputs);
        operator = n: map node n.children;
      }));

    overlays = import ./overlays inputs;
  in {
    nixosConfigurations.nixos-orion = lib.nixosSystem {
      specialArgs = {inherit theme;};
      modules = [
        ./system
        ./user
        {
          nixpkgs.overlays = overlays;
          system.extraDependencies = inputSources;
        }
        lanzaboote.nixosModules.lanzaboote
        sops-nix.nixosModules.sops
      ];
    };

    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
