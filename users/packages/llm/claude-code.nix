{ pkgs, ... }:
{
  imports = [
    ./mcp-servers/mcp.nix
  ];

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.llm-agents.claude-code;
  };
}
