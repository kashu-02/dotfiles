{ ... }:

{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    clock24 = true;
    historyLimit = 100000;
    mouse = true;
    extraConfig = ''
      set -g default-terminal 'screen-256color'
      set -g terminal-overrides 'xterm:colors=256'
      set-option -g renumber-windows on
      set-option -g status-position top
      set -g status-fg 'brightwhite'
      set -g status-bg 'colour238'
    '';
  };
}
