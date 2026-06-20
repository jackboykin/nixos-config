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
      url = "file+https://registry.npmjs.org/@oven/bun-linux-x64/canary";
      flake = false;
    };

    berkeley-mono-src = {
      url = "path:/home/jack/.local/share/font-src/berkeley-mono";
      flake = false;
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:ryoppippi/claude-code-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
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
    }: let
      specialArgs =
        inputs
        // {
          inherit
            username
            hostname
            system
            theme
            ;
        };
    in
      nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./hosts/${hostname}/host.nix
          ./modules/modules.nix
          {nixpkgs.overlays = overlays;}
          lanzaboote.nixosModules.lanzaboote
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = specialArgs;
              users.${username} = import ./users/${username}/user.nix;
            };
          }
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
