{theme, ...}: let
  c = theme.colors;
in {
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
    theme[graph_text]="${c.flamingo}"
    theme[meter_bg]="${c.surface1}"
    theme[proc_misc]="${c.surface1}"

    theme[cpu_box]="${c.mauve}"
    theme[mem_box]="${c.green}"
    theme[net_box]="${c.maroon}"
    theme[proc_box]="${c.blue}"
    theme[div_line]="${c.overlay0}"

    theme[temp_start]="${c.green}"
    theme[temp_mid]="${c.yellow}"
    theme[temp_end]="${c.red}"

    theme[cpu_start]="${c.teal}"
    theme[cpu_mid]="${c.sky}"
    theme[cpu_end]="${c.lavender}"

    theme[free_start]="${c.mauve}"
    theme[free_mid]="${c.lavender}"
    theme[free_end]="${c.blue}"

    theme[cached_start]="${c.sky}"
    theme[cached_mid]="${c.blue}"
    theme[cached_end]="${c.lavender}"

    theme[available_start]="${c.peach}"
    theme[available_mid]="${c.maroon}"
    theme[available_end]="${c.red}"

    theme[used_start]="${c.green}"
    theme[used_mid]="${c.teal}"
    theme[used_end]="${c.sapphire}"

    theme[download_start]="${c.peach}"
    theme[download_mid]="${c.maroon}"
    theme[download_end]="${c.red}"

    theme[upload_start]="${c.green}"
    theme[upload_mid]="${c.teal}"
    theme[upload_end]="${c.sapphire}"

    theme[process_start]="${c.sky}"
    theme[process_mid]="${c.lavender}"
    theme[process_end]="${c.mauve}"
  '';
}
