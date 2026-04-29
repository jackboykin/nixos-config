{
  description = "Modular NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
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
    claude-code,
    rust-overlay,
    sops-nix,
    zig-overlay,
    ...
  }: let
    system = "x86_64-linux";
    inherit (nixpkgs) lib;
    theme = import ./lib/theme.nix {inherit lib;};

    overlays = [
      claude-code.overlays.default
      rust-overlay.overlays.default
      zig-overlay.overlays.default
    ];

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
