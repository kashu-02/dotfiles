{
  description = "kashu's Nix Configuration with flakes";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      home-manager
    }:{
    nixosConfigurations.dev-nix = let 
      username = "kashu";
      specialArgs = {
        inherit username;
      };
      in 
      nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
      	./hosts/dev-nix/dev-nix-configuration.nix
        home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/dev-nix-home.nix;
            }
      ];
    };

    nixosConfigurations.kashu-lab-nixos = let 
      username = "kashu";
      specialArgs = {
        inherit username;
      };
      in 
      nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
      	./hosts/lab-pc/kashu-lab-nixos-configuration.nix
        home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/lab-pc-home.nix;
            }
      ];
    };

    darwinConfigurations.Shunsukes-MacBook-Air = let 
      username = "shun";
      specialArgs = {
        inherit username;
      };
    in 
    nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/macbookairm1
        home-manager.darwinModules.home-manager
            {
              users.users.shun.home = "/Users/shun";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/mac-thinclient.nix;
            }
      ];
    };
   };
}
