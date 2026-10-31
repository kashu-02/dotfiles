{
  description = "kashu's Nix Configuration with flakes";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/hyprland/v0.55.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };

    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprland/hyprlang";
    };

    nix-claude-code.url = "github:ryoppippi/nix-claude-code";

    mcp-servers-nix.url = "github:natsukium/mcp-servers-nix";

    agent-skills-nix = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yomiyasu = {
      url = "github:nanaism/yomiyasu";
      flake = false;
    };

    imozuru = {
      url = "github:MaryCache/imozuru";
      flake = false;
    };

    google-skills = {
      url = "github:google/skills";
      flake = false;
    };

    supabase-agent-skills = {
      url = "github:supabase/agent-skills";
      flake = false;
    };

    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };

    vercel-agent-skills = {
      url = "github:vercel-labs/agent-skills";
      flake = false;
    };

    routeros-skills = {
      url = "github:tikoci/routeros-skills";
      flake = false;
    };

    ix-toolkit = {
      url = "github:yuu61/ix-toolkit";
      flake = false;
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs@{
      # deadnix: skip
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      home-manager,
      treefmt-nix,
      systems,
      nix-claude-code,
      llm-agents,
      ...
    }:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      nixosConfigurations.dev-nix =
        let
          username = "kashu";
          system = "x86_64-linux";
          unstable-overlays = {
            nixpkgs.overlays = [
              (_final: _prev: {
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
            ./hosts/common/nix-cache.nix
            ./hosts/dev-nix/dev-nix-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/dev-nix-home.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            unstable-overlays
            { nixpkgs.overlays = [ nix-claude-code.overlays.default ]; }
            { nixpkgs.overlays = [ (_final: _prev: { llm-agents = llm-agents.packages.${system}; }) ]; }
          ];
        };

      nixosConfigurations.kashu-lab-nixos =
        let
          username = "kashu";
          system = "x86_64-linux";
          unstable-overlays = {
            nixpkgs.overlays = [
              (_final: _prev: {
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
            ./hosts/common/nix-cache.nix
            ./hosts/lab-pc/kashu-lab-nixos-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/lab-pc-home.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            unstable-overlays
            { nixpkgs.overlays = [ nix-claude-code.overlays.default ]; }
            { nixpkgs.overlays = [ (_final: _prev: { llm-agents = llm-agents.packages.${system}; }) ]; }
          ];
        };

      nixosConfigurations.l390-laptop =
        let
          username = "kashu";
          system = "x86_64-linux";
          unstable-overlays = {
            nixpkgs.overlays = [
              (_final: _prev: {
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
            ./hosts/common/nix-cache.nix
            ./hosts/l390-laptop/l390-laptop-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/l390-laptop.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            unstable-overlays
            { nixpkgs.overlays = [ nix-claude-code.overlays.default ]; }
            { nixpkgs.overlays = [ (_final: _prev: { llm-agents = llm-agents.packages.${system}; }) ]; }
          ];
        };

      nixosConfigurations.nixos-desktop =
        let
          username = "kashu";
          system = "x86_64-linux";
          unstable-overlays = {
            nixpkgs.overlays = [
              (_final: _prev: {
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
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/common/nix-cache.nix
            ./hosts/nixos-desktop/nixos-desktop-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./users/nixos-desktop.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
            unstable-overlays
            { nixpkgs.overlays = [ nix-claude-code.overlays.default ]; }
            { nixpkgs.overlays = [ (_final: _prev: { llm-agents = llm-agents.packages.${system}; }) ]; }
          ];
        };

      darwinConfigurations.Shunsukes-MacBook-Air =
        let
          username = "shun";
          system = "aarch64-darwin";
          unstable-overlays = {
            nixpkgs.overlays = [
              (_final: _prev: {
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
            ./hosts/common/nix-cache.nix
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
            { nixpkgs.overlays = [ (_final: _prev: { llm-agents = llm-agents.packages.${system}; }) ]; }
          ];
        };

      formatter = eachSystem (pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);
    };
}
