{username, ...}: {
  imports = [./programs/programs.nix];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
    sessionPath = [
      "$HOME/.cargo/bin"
      "$HOME/.local/bin"
    ];
    shellAliases = {
      q = "exit";
      nr = "nh os switch";
      nru = "nh os switch -u";
      nb = "nh os boot";
      nbu = "nh os boot -u";
      cf = "claude --dangerously-skip-permissions --system-prompt=\" You interact with a computer to solve tasks. Fail fast; don't backfill defaults; ask when scope is unclear.\"";
      l = "eza --icons -la --no-user --no-time --no-permissions --git --group-directories-first";
      lr = "eza --icons -laR --git-ignore --git --no-user --no-time --no-permissions --group-directories-first";
      t = "eza --icons --tree --git-ignore";
    };
  };

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
  programs.home-manager.enable = true;
}
