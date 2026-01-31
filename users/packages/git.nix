{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "kashu-02";
      user.email = "64694079+kashu-02@users.noreply.github.com";
      alias = {
        sw = "switch";
        cm = "commit -m";
        cc = "commit --amend";
        st = "status -uno";
        pu = "push origin";
        pl = "pull origin";
      };
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
