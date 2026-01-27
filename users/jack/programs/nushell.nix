{theme, ...}: let
  inherit (theme) colors;
in {
  programs.nushell = {
    enable = true;

    settings = {
      show_banner = false;
      edit_mode = "vi";
      cursor_shape = {
        vi_insert = "line";
        vi_normal = "block";
      };
      completions = {
        case_sensitive = false;
        quick = true;
        partial = true;
        algorithm = "fuzzy";
      };
      history = {
        max_size = 10000;
        sync_on_enter = true;
        file_format = "sqlite";
      };
    };

    extraConfig = ''
      $env.config.color_config = {
        separator: "${colors.subtext0}"
        leading_trailing_space_bg: { attr: n }
        header: { fg: "${colors.green}" attr: b }
        empty: "${colors.blue}"
        bool: "${colors.orange}"
        int: "${colors.orange}"
        filesize: "${colors.cyan}"
        duration: "${colors.orange}"
        date: "${colors.purple}"
        range: "${colors.orange}"
        float: "${colors.orange}"
        string: "${colors.green}"
        nothing: "${colors.red}"
        binary: "${colors.orange}"
        cell-path: "${colors.orange}"
        row_index: { fg: "${colors.green}" attr: b }
        record: "${colors.text}"
        list: "${colors.text}"
        hints: "${colors.subtext0}"

        shape_garbage: { fg: "${colors.base00}" bg: "${colors.red}" attr: b }
        shape_binary: "${colors.orange}"
        shape_bool: "${colors.cyan}"
        shape_int: "${colors.orange}"
        shape_float: "${colors.orange}"
        shape_range: "${colors.orange}"
        shape_internalcall: { fg: "${colors.cyan}" attr: b }
        shape_external: "${colors.cyan}"
        shape_externalarg: "${colors.green}"
        shape_literal: "${colors.orange}"
        shape_operator: "${colors.yellow}"
        shape_signature: { fg: "${colors.green}" attr: b }
        shape_string: "${colors.green}"
        shape_string_interpolation: { fg: "${colors.cyan}" attr: b }
        shape_datetime: { fg: "${colors.cyan}" attr: b }
        shape_list: { fg: "${colors.cyan}" attr: b }
        shape_table: { fg: "${colors.blue}" attr: b }
        shape_record: { fg: "${colors.cyan}" attr: b }
        shape_block: { fg: "${colors.blue}" attr: b }
        shape_filepath: "${colors.cyan}"
        shape_directory: "${colors.cyan}"
        shape_globpattern: { fg: "${colors.cyan}" attr: b }
        shape_variable: "${colors.purple}"
        shape_flag: { fg: "${colors.blue}" attr: b }
        shape_custom: "${colors.green}"
        shape_nothing: "${colors.red}"
      }
    '';

    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
    };
  };
}
