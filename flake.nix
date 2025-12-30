{
  description = "Modular NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      # Use the same nixpkgs as the main flake to avoid duplicates
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secure boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    # Manage dotfiles and user packages
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix User Repository - extra packages and Firefox extensions
    nur = {
      url = "github:nix-community/NUR";
    };
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

      # Helper function to create a NixOS configuration for a host
      mkHost =
        {
          hostname,
          username,
          extraModules ? [ ],
        }:
        let
          # Variables passed to all modules
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
              # Use system nixpkgs instead of home-manager's own
              home-manager.useGlobalPkgs = true;
              # Install packages to /etc/profiles instead of ~/.nix-profile
              home-manager.useUserPackages = true;
              # Rename conflicting files instead of failing
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
