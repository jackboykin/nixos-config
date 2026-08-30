{
  pkgs,
  lib,
  ...
}: {
  users.users.jack.packages = [pkgs.carapace];

  programs.nushell.autoloads = [
    (pkgs.runCommand "carapace-nushell" {} ''
      mkdir -p $out/share/nushell/vendor/autoload
      ${lib.getExe pkgs.carapace} _carapace nushell \
        | sed 's|"/homeless-shelter|$"($env.HOME)|g' \
        > $out/share/nushell/vendor/autoload/30-carapace.nu
    '')
  ];
}
