{ theme, ... }:
let
  c = theme.colors;
in
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "blackberry-aquamarine";
      theme_background = true;
      update_ms = 100;
      proc_sorting = "memory";
      show_cpu_watts = true;
      io_mode = true;
    };
  };

  xdg.configFile."btop/themes/blackberry-aquamarine.theme".text = ''
    theme[main_bg]="${c.base}"
    theme[main_fg]="${c.text}"
    theme[title]="${c.text}"
    theme[hi_fg]="${c.blue}"
    theme[selected_bg]="${c.surface2}"
    theme[selected_fg]="${c.text}"
    theme[inactive_fg]="${c.surface1}"
    theme[graph_text]="${c.subtext1}"
    theme[meter_bg]="${c.surface1}"
    theme[proc_misc]="${c.surface1}"

    theme[cpu_box]="${c.teal}"
    theme[mem_box]="${c.sky}"
    theme[net_box]="${c.orange}"
    theme[proc_box]="${c.purple}"
    theme[div_line]="${c.overlay0}"

    theme[temp_start]="${c.green}"
    theme[temp_mid]="${c.yellow}"
    theme[temp_end]="${c.red}"

    theme[cpu_start]="${c.green}"
    theme[cpu_mid]="${c.orange}"
    theme[cpu_end]="${c.red}"

    theme[free_start]="${c.sky}"
    theme[free_mid]="${c.blue}"
    theme[free_end]="${c.purple}"

    theme[cached_start]="${c.cyan}"
    theme[cached_mid]="${c.blue}"
    theme[cached_end]="${c.maroon}"

    theme[available_start]="${c.orange}"
    theme[available_mid]="${c.yellow}"
    theme[available_end]="${c.orange}"

    theme[used_start]="${c.green}"
    theme[used_mid]="${c.green}"
    theme[used_end]="${c.cyan}"

    theme[download_start]="${c.orange}"
    theme[download_mid]="${c.orange}"
    theme[download_end]="${c.red}"

    theme[upload_start]="${c.green}"
    theme[upload_mid]="${c.green}"
    theme[upload_end]="${c.cyan}"

    theme[process_start]="${c.cyan}"
    theme[process_mid]="${c.maroon}"
    theme[process_end]="${c.purple}"
  '';
}
