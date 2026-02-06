{
  theme,
  pkgs,
  ...
}: let
  inherit (theme) colors;
in {
  programs.nushell = {
    enable = true;

    settings = {
      show_banner = false;
      edit_mode = "emacs";
      cursor_shape = {
        emacs = "line";
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
        shape_closure: { fg: "${colors.blue}" attr: b }
        shape_keyword: { fg: "${colors.purple}" attr: b }
        shape_pipe: "${colors.yellow}"
        shape_redirection: "${colors.purple}"
        shape_and: { fg: "${colors.yellow}" attr: b }
        shape_or: { fg: "${colors.yellow}" attr: b }
        shape_raw_string: "${colors.green}"
        shape_match_pattern: "${colors.orange}"
      }

      $env.config.keybindings = ($env.config.keybindings | append [
        {
          name: history_menu
          modifier: control
          keycode: char_r
          mode: [emacs vi_insert vi_normal]
          event: {
            send: executehostcommand
            cmd: "commandline edit --replace (
              history
              | get command
              | reverse
              | uniq
              | str join (char -i 0)
              | fzf --scheme=history --read0 --layout=reverse --height=40% -q (commandline)
              | decode utf-8
              | str trim
            )"
          }
        }
        {
          name: fzf_file
          modifier: control
          keycode: char_t
          mode: [emacs vi_insert]
          event: {
            send: executehostcommand
            cmd: "commandline edit --insert (
              fd --type f --hidden --exclude .git
              | fzf --layout=reverse --height=40%
              | decode utf-8
              | str trim
            )"
          }
        }
        {
          name: fzf_directory
          modifier: alt
          keycode: char_c
          mode: [emacs vi_insert]
          event: {
            send: executehostcommand
            cmd: "let dir = (
              fd --type d --hidden --exclude .git
              | fzf --layout=reverse --height=40%
              | decode utf-8
              | str trim
            ); if ($dir | is-not-empty) { cd $dir }"
          }
        }
      ])
    '';

    extraEnv = ''
      if ("/run/secrets/brave-api-key" | path exists) {
        $env.BRAVE_API_KEY = (open /run/secrets/brave-api-key | str trim)
      }
    '';

    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
    };
  };

  home.packages = with pkgs; [
    carapace
  ];

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };
}
