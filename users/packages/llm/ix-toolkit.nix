{ inputs, pkgs, ... }:
let
  # ix-ssh CLI used by the ix-toolkit skills (see agent-skills.nix).
  ix-toolkit = pkgs.python3Packages.buildPythonApplication {
    pname = "ix-toolkit";
    version = "0.1.0";
    pyproject = true;
    src = inputs.ix-toolkit;

    build-system = [ pkgs.python3Packages.hatchling ];
    dependencies = with pkgs.python3Packages; [
      netmiko
      paramiko
    ];
    # nixpkgs ships netmiko 4.6; upstream requires >=4.7.
    pythonRelaxDeps = [ "netmiko" ];

    doCheck = false;
  };
in
{
  home.packages = [ ix-toolkit ];
}
