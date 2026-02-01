{
  pkgs,
  lib,
  theme,
  ...
}: let
  inherit (theme) colors ui;

  prettierLang = name: parser: {
    inherit name;
    auto-format = true;
    formatter = {
      command = lib.getExe pkgs.nodePackages.prettier;
      args = ["--parser" parser];
    };
  };
in {
  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      nixd
      alejandra
      rust-analyzer
      nodePackages.typescript-language-server
      nodePackages.prettier
      pyright
    ];

    settings = {
      theme = "bellatrix";

      editor = {
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        true-color = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        scrolloff = 8;
        auto-save = {
          focus-lost = true;
          after-delay.enable = true;
        };

        bufferline = "multiple";
        indent-guides.render = true;
        soft-wrap = {
          enable = true;
          wrap-at-text-width = true;
        };

        lsp = {
          display-inlay-hints = true;
          display-messages = true;
        };

        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "disable";
        };

        statusline = {
          left = ["mode" "spinner" "version-control" "file-name"];
          right = ["diagnostics" "workspace-diagnostics" "selections" "position" "file-type"];
          separator = "│";
        };
      };

      keys = {
        normal = {
          "C-s" = ":write";
          "U" = "redo";

          "C-h" = "jump_view_left";
          "C-j" = "jump_view_down";
          "C-k" = "jump_view_up";
          "C-l" = "jump_view_right";

          "A-." = "goto_next_buffer";
          "A-," = "goto_previous_buffer";
          "A-w" = ":buffer-close";

          "n" = ["search_next" "align_view_center"];
          "N" = ["search_prev" "align_view_center"];

          "space" = {
            "f" = "file_picker";
            "b" = "buffer_picker";
            "g" = "changed_file_picker";
            "s" = "symbol_picker";
            "d" = "diagnostics_picker";
            "/" = "global_search";

            "k" = "hover";
            "r" = "rename_symbol";
            "a" = "code_action";

            "y" = "yank_to_clipboard";
            "p" = "paste_clipboard_after";

            "w" = {
              "v" = "vsplit";
              "s" = "hsplit";
              "h" = "jump_view_left";
              "j" = "jump_view_down";
              "k" = "jump_view_up";
              "l" = "jump_view_right";
            };

            "t" = {
              "w" = ":toggle soft-wrap.enable";
              "l" = ":toggle lsp.display-inlay-hints";
              "i" = ":toggle indent-guides.render";
            };
          };

          "g" = {
            "d" = "goto_definition";
            "r" = "goto_reference";
            "i" = "goto_implementation";
          };

          "m" = {
            "m" = "match_brackets";
            "s" = "surround_add";
            "r" = "surround_replace";
            "d" = "surround_delete";
          };
        };

        insert = {
          "C-s" = ":write";
        };
      };
    };

    languages = {
      language-server = {
        rust-analyzer.config = {
          check.command = "clippy";
          inlayHints = {
            bindingModeHints.enable = true;
            closureReturnTypeHints.enable = "always";
          };
        };
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = lib.getExe pkgs.alejandra;
          language-servers = ["nixd"];
        }
        {
          name = "rust";
          auto-format = true;
          language-servers = ["rust-analyzer"];
        }
        {
          name = "python";
          auto-format = true;
          language-servers = ["pyright"];
        }
        (prettierLang "typescript" "typescript")
        (prettierLang "javascript" "babel")
        (prettierLang "tsx" "typescript")
        (prettierLang "json" "json")
        (prettierLang "css" "css")
        (prettierLang "html" "html")
        {
          name = "markdown";
          auto-format = true;
          soft-wrap.enable = true;
        }
        {
          name = "toml";
          auto-format = true;
        }
        {
          name = "yaml";
          auto-format = true;
        }
      ];
    };

    themes.bellatrix = {
      "ui.background" = {bg = colors.base;};
      "ui.popup" = {
        fg = colors.text;
        bg = colors.surface0;
      };
      "ui.text" = colors.text;
      "ui.text.focus" = {
        fg = colors.text;
        bg = colors.surface1;
      };
      "ui.virtual.indent-guide" = colors.surface1;
      "ui.virtual.inlay-hint" = {
        fg = colors.subtext0;
        modifiers = ["italic"];
      };
      "ui.selection" = {bg = ui.selection;};
      "ui.cursor.primary" = {
        fg = colors.base;
        bg = colors.purple;
      };
      "ui.cursor.insert" = {
        fg = colors.base;
        bg = colors.green;
      };
      "ui.linenr" = colors.surface2;
      "ui.linenr.selected" = {
        fg = colors.purple;
        modifiers = ["bold"];
      };
      "ui.statusline" = {
        fg = colors.text;
        bg = colors.surface0;
      };
      "ui.statusline.normal" = {
        fg = colors.base;
        bg = colors.blue;
        modifiers = ["bold"];
      };
      "ui.statusline.insert" = {
        fg = colors.base;
        bg = colors.green;
        modifiers = ["bold"];
      };
      "ui.statusline.select" = {
        fg = colors.base;
        bg = colors.purple;
        modifiers = ["bold"];
      };
      "ui.bufferline.active" = {
        fg = colors.text;
        bg = colors.surface1;
        modifiers = ["bold"];
      };

      "error" = colors.error;
      "warning" = colors.warning;
      "info" = colors.info;
      "hint" = colors.hint;
      "diagnostic.error" = {
        underline = {
          color = colors.error;
          style = "curl";
        };
      };

      "diff.plus" = colors.gitAdded;
      "diff.minus" = colors.gitDeleted;
      "diff.delta" = colors.gitModified;

      "type" = {
        fg = colors.yellow;
        modifiers = ["italic"];
      };
      "constant" = colors.orange;
      "string" = colors.green;
      "comment" = {
        fg = colors.surface2;
        modifiers = ["italic"];
      };
      "variable.parameter" = {
        fg = colors.red;
        modifiers = ["italic"];
      };
      "variable.other.member" = colors.cyan;
      "keyword" = colors.purple;
      "function" = {
        fg = colors.blue;
        modifiers = ["italic"];
      };
      "namespace" = {
        fg = colors.yellow;
        modifiers = ["italic"];
      };

      "markup.heading" = {
        fg = colors.yellow;
        modifiers = ["bold"];
      };
      "markup.link.url" = {
        fg = colors.cyan;
        underline.style = "line";
      };
    };
  };
}
