{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "kashu-02";
    userEmail = "64694079+kashu-02@users.noreply.github.com";
    signing.key = "0F4484A65691E216";
    signing.signByDefault = true;
  };
}