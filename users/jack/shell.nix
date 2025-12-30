{...}: {
  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
  ];

  home.shellAliases = {
    a = "nvim";
    q = "exit";

    nr = "nh os switch";
    nru = "nh os switch -u";

    cat = "bat";
    ga = "git add -A";
    lz = "lazygit";
    g = "git";
    gc = "git commit -m";

    ls = "eza --icons --group-directories-first";
    l = "eza --icons -la --no-user --no-time --no-permissions --git --group-directories-first";
    lr = "eza --icons -laR --git-ignore --git --no-user --no-time --no-permissions --group-directories-first";
    tree = "eza --icons --tree --git-ignore";
    treea = "eza --icons --tree -a";

    grep = "rg";
  };
}
