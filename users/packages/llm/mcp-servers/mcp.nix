{
  config,
  inputs,
  pkgs,
  ...
}:

let
  mcpEval = inputs.mcp-servers-nix.lib.evalModule pkgs.unstable {
    programs = {
      context7.enable = true;
      fetch.enable = true;

      filesystem = {
        enable = true;
        args = [ config.home.homeDirectory ];
      };

      git.enable = true;
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
