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

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    lanzaboote,
    llm-agents,
    nur,
    rust-overlay,
    sops-nix,
    ...
  }: let
    system = "x86_64-linux";
    inherit (nixpkgs) lib;
    theme = import ./lib/theme.nix {inherit lib;};

    mkHost = {
      hostname,
      username,
      extraModules ? [],
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
        modules =
          [
            ./hosts/${hostname}/host.nix
            ./modules/modules.nix
            {nixpkgs.overlays = [nur.overlays.default rust-overlay.overlays.default];}
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
          ]
          ++ extraModules;
      };
  in {
    nixosConfigurations.nixos-orion = mkHost {
      hostname = "nixos-orion";
      username = "jack";
    };

    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
