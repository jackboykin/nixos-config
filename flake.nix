{
  description = "Modular NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
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

    nur.url = "github:nix-community/NUR";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      lanzaboote,
      nur,
      ...
    }:
    let
      system = "x86_64-linux";
      inherit (nixpkgs) lib;
      theme = import ./lib/theme.nix { inherit lib; };

      mkHost =
        {
          hostname,
          username,
          extraModules ? [ ],
        }:
        let
          specialArgs = inputs // {
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

            # Make NUR packages available as pkgs.nur.*
            { nixpkgs.overlays = [ nur.overlays.default ]; }

            lanzaboote.nixosModules.lanzaboote

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${username} = import ./users/${username}/user.nix;
            }
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        # Primary desktop
        nixos-orion = mkHost {
          hostname = "nixos-orion";
          username = "jack";
        };

        # Add more hosts here:
        # laptop = mkHost {
        #   hostname = "laptop";
        #   username = "jack";
        #   extraModules = [ ./hosts/laptop/extra.nix ];
        # };
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
    };
}
