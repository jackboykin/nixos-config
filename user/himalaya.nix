{pkgs, ...}: {
  users.users.jack.packages = [pkgs.himalaya];

  castle.links.".config/himalaya/config.toml" = pkgs.writeText "himalaya-config" ''
    [accounts.lore]
    default = true

    [accounts.lore.mbox]
    root = "."
  '';
}
