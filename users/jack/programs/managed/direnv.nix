# Direnv: automatically loads environment when entering directories with .envrc
{pkgs, ...}: {
  programs.direnv = {
    enable = true;
    # Don't print messages when loading/unloading
    silent = true;
    # Faster nix integration with cached environments
    nix-direnv.enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    # Store direnv layouts in cache instead of project directories
    # Keeps project dirs clean and prevents .direnv folders everywhere
    stdlib = ''
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      declare -A direnv_layout_dirs

      direnv_layout_dir() {
        echo "''${direnv_layout_dirs[$PWD]:=$(
          echo -n "$XDG_CACHE_HOME"/direnv/layouts/
          echo -n "$PWD" | ${pkgs.perl}/bin/shasum | cut -d ' ' -f 1
        )}"
      }
    '';
  };
}
