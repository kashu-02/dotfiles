{
  description = "kashu's Nix Configuration with flakes";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      treefmt-nix,
      systems,
    }:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      nixosConfigurations.dev-nix =
        let
          username = "kashu";
          specialArgs = {
            inherit username;
          };
          system = "x86_64-linux";
          unstable-overlays = {
            nixpkgs.overlays = [
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                };
              })
            ];
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/dev-nix/dev-nix-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/dev-nix-home.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            unstable-overlays
          ];
        };

      nixosConfigurations.kashu-lab-nixos =
        let
          username = "kashu";
          specialArgs = {
            inherit username;
          };
          system = "x86_64-linux";
          unstable-overlays = {
            nixpkgs.overlays = [
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                };
              })
            ];
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/lab-pc/kashu-lab-nixos-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/lab-pc-home.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            unstable-overlays
          ];
        };

      nixosConfigurations.l390-laptop =
        let
          username = "kashu";
          specialArgs = {
            inherit username;
          };
          system = "x86_64-linux";
          unstable-overlays = {
            nixpkgs.overlays = [
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                };
              })
            ];
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/l390-laptop/l390-laptop-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/l390-laptop.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            unstable-overlays
          ];
        };

      darwinConfigurations.Shunsukes-MacBook-Air =
        let
          username = "shun";
          specialArgs = {
            inherit username;
          };
          system = "aarch64-darwin";
          unstable-overlays = {
            nixpkgs.overlays = [
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                };
              })
            ];
          };
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./hosts/macbookairm1
            home-manager.darwinModules.home-manager
            {
              users.users.shun.home = "/Users/shun";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/mac-thinclient.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            unstable-overlays
          ];
        };

      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
    };
}
