{
  pkgs,
  theme,
  ...
}: let
  c = theme.colors;
in {
  home.packages = [pkgs.ghostty];

  xdg.configFile."ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    font-size = 13

    background = ${c.base}
    foreground = ${c.text}
    selection-background = ${c.surface1}
    selection-foreground = ${c.text}
    cursor-color = ${c.rosewater}

    palette = 0=${c.surface0}
    palette = 1=${c.red}
    palette = 2=${c.green}
    palette = 3=${c.yellow}
    palette = 4=${c.blue}
    palette = 5=${c.pink}
    palette = 6=${c.teal}
    palette = 7=${c.subtext1}
    palette = 8=${c.surface1}
    palette = 9=${c.red}
    palette = 10=${c.green}
    palette = 11=${c.yellow}
    palette = 12=${c.blue}
    palette = 13=${c.pink}
    palette = 14=${c.teal}
    palette = 15=${c.text}

    cursor-style = block
    cursor-style-blink = false

    mouse-hide-while-typing = true
    copy-on-select = clipboard
    confirm-close-surface = false

    window-padding-x = 8
    window-padding-y = 6
    window-decoration = false

    keybind = ctrl+shift+r=reload_config
    keybind = ctrl+shift+c=copy_to_clipboard
    keybind = ctrl+shift+v=paste_from_clipboard
  '';
}
