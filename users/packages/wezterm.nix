_:

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      local wezterm = require 'wezterm'

      local config = wezterm.config_builder()

      config.use_ime = true

      config.enable_tab_bar = false

      config.check_for_updates = false

      font = wezterm.font_with_fallback {
        'JetBrains Mono',
        'Noto Sans CJK JP',
      }

      return config
    '';
  };
}
