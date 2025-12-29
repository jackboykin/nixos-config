{
  description = "My NixOS Flake Configuration";

  inputs = {
    # Pin to the 25.11 release
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Added Home Manager input (matching your 25.11 version)
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos-orion = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix

        # Make home-manager a module of the system
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # This tells Home Manager to use a file named home.nix for user 'jack'
          home-manager.users.jack = import ./home.nix;
        }
      ];
    };
  };
}
