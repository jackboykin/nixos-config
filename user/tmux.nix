{
  pkgs,
  theme,
  ...
}: let
  inherit (theme) colors;
in {
  users.users.jack.packages = [pkgs.tmux];

  castle.links.".config/tmux" = pkgs.writeTextDir "tmux.conf" ''
    set -g default-terminal "tmux-256color"
    set -ga terminal-features ",*:RGB"
    set -g mouse on
    set -g base-index 1
    set -g escape-time 0
    set -g focus-events on
    set -g history-limit 50000

    set -g status-style "fg=${colors.subtext0},bg=${colors.mantle}"
    set -g status-left ""
    set -g status-right " #S "
    set -g window-status-current-style "fg=${colors.orange}"
    set -g pane-border-style "fg=${colors.surface1}"
    set -g pane-active-border-style "fg=${colors.surface2}"
    set -g message-style "fg=${colors.text},bg=${colors.surface1}"
  '';
}
