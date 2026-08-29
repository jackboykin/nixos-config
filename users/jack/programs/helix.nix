{
  pkgs,
  lib,
  theme,
  username,
  ...
}: let
  inherit (theme) colors ui;

  toml = pkgs.formats.toml {};

  prettierLang = name: parser: {
    inherit name;
    auto-format = true;
    formatter = {
      command = lib.getExe pkgs.prettier;
      args = ["--parser" parser];
    };
  };
in {
  users.users.${username}.packages = [pkgs.helix];

  environment.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  castle.links.".config/helix" = pkgs.linkFarm "helix-config" {
    "config.toml" = ./helix-config.toml;

    "languages.toml" = toml.generate "languages.toml" {
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

    "themes/bellatrix.toml" = toml.generate "bellatrix.toml" {
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
