{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "kashu-02";
    userEmail = "64694079+kashu-02@users.noreply.github.com";
    aliases = {
      sw = "switch";
      cm = "commit -m";
      cc = "commit --amend";
      st = "status -uno";
      pu = "push origin";
      pl = "pull origin";
    };
    ignores = [
      ".idea/"
      ".direnv/"
    ];
    signing = {
      key = "0F4484A65691E216";
      signByDefault = true;
    };
  };
}
