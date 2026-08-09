{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.llm-agents.opencode;
  };
}
