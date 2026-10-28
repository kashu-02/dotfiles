{ inputs, pkgs, ... }:
{
  disabledModules = [ "programs/t3code.nix" ];
  imports = [ "${inputs.home-manager-unstable}/modules/programs/t3code.nix" ];

  programs.t3code = {
    enable = true;
    package = pkgs.llm-agents.t3code;
    server.enable = true;
  };
}
