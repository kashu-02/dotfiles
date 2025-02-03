{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    plugins = with pkgs; [
      vimPlugins.coc-nvim
    ];
  }; 
}