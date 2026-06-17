{username, ...}: {
  imports = [./programs/programs.nix];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
    enableNixpkgsReleaseCheck = false;
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
      cf = "claude --dangerously-skip-permissions --system-prompt=\"\"";
      l = "eza --icons -la --no-user --no-time --no-permissions --git --group-directories-first";
      lr = "eza --icons -laR --git-ignore --git --no-user --no-time --no-permissions --group-directories-first";
      t = "eza --icons --tree --git-ignore";
    };
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    configFile."baloofilerc".text = ''
      [Basic Settings]
      Indexing-Enabled=false
    '';
    configFile."krunnerrc".text = ''
      [Plugins]
      baloosearchEnabled=false
      bookmarksEnabled=false
      browserhistoryEnabled=false
      browsertabsEnabled=false
      recentdocumentsEnabled=false
      webshortcutsEnabled=false
      unitconverterEnabled=false
      CharacterRunnerEnabled=false
      krunner_spellcheckEnabled=false
      org.kde.activities2Enabled=false
      org.kde.datetimeEnabled=false
      placesEnabled=false
      desktopsessionsEnabled=false
      katesessionsEnabled=false
    '';
  };
  programs.home-manager.enable = true;
}
