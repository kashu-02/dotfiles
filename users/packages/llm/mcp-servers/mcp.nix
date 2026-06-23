{
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.mcp-servers-nix.homeManagerModules.default
  ];

  programs.mcp.enable = true;

  mcp-servers.programs = {
    context7.enable = true;
    fetch.enable = true;
    filesystem = {
      enable = true;
      args = [ config.home.homeDirectory ];
    };
    git.enable = true;
    nixos.enable = true;
  };
}
