{ theme, ... }:
let
  colors = theme.colors;
in
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "colors";
      theme_background = true;
      update_ms = 100;
      proc_sorting = "memory";
      show_cpu_watts = true;
      io_mode = true;
    };
  };

  xdg.configFile."btop/themes/colors.theme".text = ''
    theme[main_bg]="${colors.base}"
    theme[main_fg]="${colors.text}"
    theme[title]="${colors.text}"
    theme[hi_fg]="${colors.blue}"
    theme[selected_bg]="${colors.surface2}"
    theme[selected_fg]="${colors.text}"
    theme[inactive_fg]="${colors.surface1}"
    theme[graph_text]="${colors.subtext1}"
    theme[meter_bg]="${colors.surface1}"
    theme[proc_misc]="${colors.surface1}"

    theme[cpu_box]="${colors.teal}"
    theme[mem_box]="${colors.sky}"
    theme[net_box]="${colors.orange}"
    theme[proc_box]="${colors.purple}"
    theme[div_line]="${colors.overlay0}"

    theme[temp_start]="${colors.green}"
    theme[temp_mid]="${colors.yellow}"
    theme[temp_end]="${colors.red}"

    theme[cpu_start]="${colors.green}"
    theme[cpu_mid]="${colors.orange}"
    theme[cpu_end]="${colors.red}"

    theme[free_start]="${colors.sky}"
    theme[free_mid]="${colors.blue}"
    theme[free_end]="${colors.purple}"

    theme[cached_start]="${colors.cyan}"
    theme[cached_mid]="${colors.blue}"
    theme[cached_end]="${colors.maroon}"

    theme[available_start]="${colors.orange}"
    theme[available_mid]="${colors.yellow}"
    theme[available_end]="${colors.orange}"

    theme[used_start]="${colors.green}"
    theme[used_mid]="${colors.green}"
    theme[used_end]="${colors.cyan}"

    theme[download_start]="${colors.orange}"
    theme[download_mid]="${colors.orange}"
    theme[download_end]="${colors.red}"

    theme[upload_start]="${colors.green}"
    theme[upload_mid]="${colors.green}"
    theme[upload_end]="${colors.cyan}"

    theme[process_start]="${colors.cyan}"
    theme[process_mid]="${colors.maroon}"
    theme[process_end]="${colors.purple}"
  '';
}
