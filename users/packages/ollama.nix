{ pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama;
    host = "0.0.0.0";
  };
}
