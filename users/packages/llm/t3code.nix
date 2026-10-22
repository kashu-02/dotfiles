{ pkgs, ... }:
{
  home.packages = [
    pkgs.llm-agents.t3code
    pkgs.llm-agents.t3code-desktop
  ];
}
