{ pkgs, ...} : {
  programs.zsh = {
    enable = true;
    shellAliases = {
      la = "ls -alh";
      ll = "ls -lh";
    };
    initExtra = ''
      fastfetch
    '';
    zplug = {
      enable = true;
      plugins = [
        { name = "mafredri/zsh-async"; tags = [from:github]; }
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "sindresorhus/pure"; tags = [use:pure.zsh from:github as:theme]; }
      ];
    };
  };
}