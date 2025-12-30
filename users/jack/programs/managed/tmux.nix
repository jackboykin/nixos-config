{
  pkgs,
  theme,
  ...
}: let
  c = theme.colors;
in {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    escapeTime = 0;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    historyLimit = 50000;

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      {
        plugin = yank;
        extraConfig = "set -g @yank_selection_mouse 'clipboard'";
      }
    ];

    extraConfig = ''
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -sg terminal-overrides ",*:RGB"
      set -g renumber-windows on
      set -g repeat-time 1000

      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      bind-key "|" split-window -h -c "#{pane_current_path}"
      bind-key "\\" split-window -fh -c "#{pane_current_path}"
      bind-key "-" split-window -v -c "#{pane_current_path}"
      bind-key "_" split-window -fv -c "#{pane_current_path}"

      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      set -g status-position bottom
      set -g status-justify left
      set -g status-left " "
      set -g status-right "#[fg=${c.subtext0}]%H:%M "
      set -g status-style "bg=default"

      set -g window-status-separator " "
      set -g window-status-format "#[fg=#{?#{==:#I,1},${c.red},#{?#{==:#I,2},${c.mauve},#{?#{==:#I,3},${c.blue},${c.teal}}}}]●"
      set -g window-status-current-format "#[fg=${c.yellow},bold]●"

      set -g pane-border-lines single
      set -g pane-border-style "fg=${c.surface1}"
      set -g pane-active-border-style "fg=${c.mauve}"

      set -g message-style "bg=${c.surface0},fg=${c.text}"
      set -g message-command-style "bg=${c.surface0},fg=${c.text}"
      set -g mode-style "bg=${c.surface1},fg=${c.text}"
    '';
  };
}
