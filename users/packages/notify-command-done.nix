{ pkgs, ... }:

let
  notify-command-done = pkgs.buildGoModule rec {
    pname = "notify-command-done";
    version = "90a550a7079b445f2b37740b66e7fcc8bf745a1f";

    src = pkgs.fetchFromGitHub {
      owner = "kashu-02";
      repo = "notify-done-to-slack";
      rev = version;
      hash = "sha256-OnL+ToltWq9sHEV1VZs6tXC802hTxM0kYwG4RfqDjF8=";
    };

    vendorHash = "sha256-InM4nDMCBNGLy4INGGBR896YZgCchqF1/pBGQMK1ruc=";
  };
in
{
  home.packages = [ notify-command-done ];
}
