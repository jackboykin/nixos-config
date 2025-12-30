{ theme, ... }:
let
  c = theme.colors;
in
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "edo";
      theme_background = true;
      update_ms = 100;
      proc_sorting = "memory";
      show_cpu_watts = true;
      io_mode = true;
    };
  };

  xdg.configFile."btop/themes/edo.theme".text = ''
    theme[main_bg]="${c.base}"
    theme[main_fg]="${c.text}"
    theme[title]="${c.text}"
    theme[hi_fg]="${c.blue}"
    theme[selected_bg]="${c.surface1}"
    theme[selected_fg]="${c.blue}"
    theme[inactive_fg]="${c.surface1}"
    theme[graph_text]="${c.pink}"
    theme[meter_bg]="${c.surface1}"
    theme[proc_misc]="${c.surface1}"

    theme[cpu_box]="${c.magenta}"
    theme[mem_box]="${c.green}"
    theme[net_box]="${c.orange}"
    theme[proc_box]="${c.blue}"
    theme[div_line]="${c.overlay0}"

    theme[temp_start]="${c.green}"
    theme[temp_mid]="${c.yellow}"
    theme[temp_end]="${c.red}"

    theme[cpu_start]="${c.teal}"
    theme[cpu_mid]="${c.cyan}"
    theme[cpu_end]="${c.purple}"

    theme[free_start]="${c.magenta}"
    theme[free_mid]="${c.purple}"
    theme[free_end]="${c.blue}"

    theme[cached_start]="${c.cyan}"
    theme[cached_mid]="${c.blue}"
    theme[cached_end]="${c.purple}"

    theme[available_start]="${c.orange}"
    theme[available_mid]="${c.red}"
    theme[available_end]="${c.pink}"

    theme[used_start]="${c.green}"
    theme[used_mid]="${c.darkGreen}"
    theme[used_end]="${c.cyan}"

    theme[download_start]="${c.orange}"
    theme[download_mid]="${c.red}"
    theme[download_end]="${c.magenta}"

    theme[upload_start]="${c.green}"
    theme[upload_mid]="${c.darkGreen}"
    theme[upload_end]="${c.cyan}"

    theme[process_start]="${c.cyan}"
    theme[process_mid]="${c.purple}"
    theme[process_end]="${c.magenta}"
  '';
}
