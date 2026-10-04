{pkgs, ...}: {
  users.users.jack.packages = [(pkgs.fetch.override {fastfetch = null;})];

  castle.links.".config/fetch/logo.txt" = pkgs.runCommand "fetch-logo.txt" {} ''
    { echo '# distro: nixos'; ${pkgs.fastfetch}/bin/fastfetch -l nixos -s break --pipe false; } > $out
  '';
}
