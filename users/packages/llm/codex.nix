{ pkgs, ... }:
{
  programs.codex = {
    enable = true;
    enableMcpIntegration = false;
    package = pkgs.llm-agents.codex;

#    settings = {
#      approval_policy = "on-request";
#      sandbox_mode = "workspace-write";
#    };
  };
}
