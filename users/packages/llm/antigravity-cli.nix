{ pkgs, ... }:
{
  programs.antigravity-cli = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.llm-agents.antigravity-cli;
  };
}
