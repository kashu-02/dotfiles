{
  config,
  inputs,
  pkgs,
  ...
}:

let
  servers = pkgs.unstable.extend inputs.mcp-servers-nix.overlays.default;

  # 上流の mcp-server-{fetch,git} は mcp<2 を要求するが nixpkgs の mcp は 2.x
  relaxMcp =
    drv:
    drv.overridePythonAttrs (old: {
      pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [ "mcp" ];
    });

  mcpEval = inputs.mcp-servers-nix.lib.evalModule pkgs.unstable {
    programs = {
      context7.enable = true;

      fetch = {
        enable = true;
        package = relaxMcp servers.mcp-server-fetch;
      };

      filesystem = {
        enable = true;
        args = [ config.home.homeDirectory ];
      };

      git = {
        enable = true;
        package = relaxMcp servers.mcp-server-git;
      };
      nixos.enable = true;
    };
  };
in
{
  programs.mcp = {
    enable = true;
    servers = mcpEval.config.settings.servers;
  };
}
