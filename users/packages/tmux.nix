{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    clock24 = true;
    historyLimit = 100000;
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      continuum
    ];
    extraConfig = ''
      set -g default-terminal 'screen-256color'
      set -g terminal-overrides 'xterm:colors=256'
      set-option -g renumber-windows on
      set-option -g status-position top
      set -g status-fg 'brightwhite'
      set -g status-bg 'colour238'
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '5'
      set -g @resurrect-capture-pane-contents 'on'
    '';
  };
}
