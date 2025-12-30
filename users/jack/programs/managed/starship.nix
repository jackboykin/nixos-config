{ theme, lib, ... }:
let
  c = theme.colors;
in
{
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
      # Premium Tokyo Night Style
      format = lib.concatStrings [
        "[](${c.blue})"
        "$directory"
        "[ ](fg:${c.blue} bg:${c.surface2})"
        "$git_branch"
        "$git_status"
        "[ ](fg:${c.surface2} bg:${c.surface1})"
        "$nodejs"
        "$rust"
        "$golang"
        "$python"
        "$nix_shell"
        "[ ](fg:${c.surface1} bg:${c.surface0})"
        "$time"
        "[ ](fg:${c.surface0})\n"
        "$character"
      ];

      directory = {
        style = "fg:${c.base} bg:${c.blue} bold";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = "󰉍 ";
          "Music" = "󰎆 ";
          "Pictures" = "󰉏 ";
          "Videos" = "󰉏 ";
          "Projects" = "󱔗 ";
          "Desktop" = "󰇄 ";
          "nixos-config" = "󱄅 nixos-config";
        };
      };

      git_branch = {
        symbol = "󰘬";
        style = "fg:${c.blue} bg:${c.surface2} bold";
        format = "[[ $symbol $branch ]($style)]($style)";
      };

      git_status = {
        style = "fg:${c.blue} bg:${c.surface2}";
        format = "[[($all_status$ahead_behind )]($style)]($style)";
      };

      nodejs = {
        symbol = "󰎙";
        style = "fg:${c.blue} bg:${c.surface1}";
        format = "[[ $symbol ($version) ]($style)]($style)";
      };

      rust = {
        symbol = "󱘗";
        style = "fg:${c.blue} bg:${c.surface1}";
        format = "[[ $symbol ($version) ]($style)]($style)";
      };

      golang = {
        symbol = "󰟓";
        style = "fg:${c.blue} bg:${c.surface1}";
        format = "[[ $symbol ($version) ]($style)]($style)";
      };

      python = {
        symbol = "󰌠";
        style = "fg:${c.blue} bg:${c.surface1}";
        format = "[[ $symbol ($version) ]($style)]($style)";
      };

      nix_shell = {
        symbol = "󱄅";
        style = "fg:${c.blue} bg:${c.surface1}";
        format = "[[ $symbol $state ]($style)]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "fg:${c.subtext1} bg:${c.surface0}";
        format = "[[ 󱑎 $time ]($style)]($style)";
      };

      character = {
        success_symbol = "[ ❯](bold ${c.blue})";
        error_symbol = "[ ❯](bold ${c.red})";
        vimcmd_symbol = "[ ❮](bold ${c.green})";
      };
    };
  };
}
