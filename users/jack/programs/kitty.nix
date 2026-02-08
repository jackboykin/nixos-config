{
  pkgs,
  theme,
  ...
}: let
  inherit (theme) colors;
in {
  programs.kitty = {
    enable = true;
    settings = {
      shell = "${pkgs.nushell}/bin/nu";

      font_family = theme.fonts.mono.name;
      font_size = theme.fonts.size.normal;

      cursor_shape = "beam";
      cursor_blink_interval = 0;

      window_padding_width = 8;
      background_opacity = "0.95";
      confirm_os_window_close = 0;

      enable_audio_bell = false;

      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      active_tab_foreground = colors.base;
      active_tab_background = colors.purple;
      active_tab_font_style = "bold";
      inactive_tab_foreground = colors.text;
      inactive_tab_background = colors.surface0;
      inactive_tab_font_style = "normal";

      inherit
        (colors)
        foreground
        background
        color0
        color1
        color2
        color3
        color4
        color5
        color6
        color7
        color8
        color9
        color10
        color11
        color12
        color13
        color14
        color15
        ;
      cursor = colors.cursorColor;
      cursor_text_color = colors.background;
      selection_foreground = colors.background;
      selection_background = colors.text;
      url_color = colors.blue;
    };
  };
}
