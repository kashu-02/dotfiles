{
  description = "kashu's Nix Configuration with flakes";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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
    nixosConfigurations.kashu-lab-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
      	./kashu-lab-nixos-configuration.nix
	home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.kashu = import ./home-manager/lab-pc-home.nix;
          }
      ];
    };
   };
}
