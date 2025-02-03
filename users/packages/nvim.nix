{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    extraConfig = ''
      set number relativenumber
    '';
    plugins = with pkgs.vimPlugins; [
      coc-nvim
      lualine-nvim
      neo-tree-nvim
      nvim-hlslens
      barbar-nvim
      coc-tsserver
      coc-rust-analyzer
      telescope-nvim
      gitsigns-nvim
      nvim-web-devicons
    ];
  };
}