_:
{
  programs.zsh = {
    enable = true;
    shellAliases = {
      la = "ls -alh";
      ll = "ls -lh";
    };
    initContent = ''
      fastfetch
    '';
    autosuggestion.enable = true;
    history.share = true;
    history.size = 1000000;
    syntaxHighlighting.enable = true;

    zplug = {
      enable = true;
      plugins = [
        {
          name = "mafredri/zsh-async";
          tags = [ "from:github" ];
        }
        { name = "zsh-users/zsh-autosuggestions"; }
        {
          name = "sindresorhus/pure";
          tags = [
            "use:pure.zsh"
            "from:github"
            "as:theme"
          ];
        }
      ];
    };
  };
}
