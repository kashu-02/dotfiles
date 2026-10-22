{ pkgs, ... }:
{
  home.packages = [
    pkgs.llm-agents.t3code
  ];
}
