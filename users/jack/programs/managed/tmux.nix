{
  pkgs,
  theme,
  ...
}:
let
  colors = theme.colors;
in
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    prefix = "C-Space";
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

      # prefix + C-l to clear
      bind C-l send-keys 'C-l'

      # Smart pane switching (Vim aware)
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R

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
      set -g status-right "#[fg=${colors.subtext0}]%H:%M "
      set -g status-style "bg=default"

      set -g window-status-separator " "
      set -g window-status-format "#[fg=#{?#{==:#I,1},${colors.red},#{?#{==:#I,2},${colors.purple},#{?#{==:#I,3},${colors.blue},${colors.cyan}}}}]●"
      set -g window-status-current-format "#[fg=${colors.yellow},bold]●"

      set -g pane-border-lines single
      set -g pane-border-style "fg=${colors.surface1}"
      set -g pane-active-border-style "fg=${colors.purple}"

      set -g message-style "bg=${colors.base},fg=${colors.text}"
      set -g message-command-style "bg=${colors.base},fg=${colors.text}"
      set -g mode-style "bg=${colors.surface1},fg=${colors.text}"
    '';
  };
}
