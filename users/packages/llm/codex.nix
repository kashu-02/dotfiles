{ pkgs, ... }:
{
  programs.codex = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.llm-agents.codex;
  };
}
