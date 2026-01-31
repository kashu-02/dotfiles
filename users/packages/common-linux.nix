{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./ssh.nix
    ./gpg.nix
  ];
}
