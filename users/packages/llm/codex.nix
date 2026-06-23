{ pkgs, ... }:
{
  programs.codex = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.unstable.codex;
  };
}
