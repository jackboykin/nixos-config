{
  pkgs,
  lib,
  username,
  ...
}: {
  users.users.${username}.packages = [pkgs.zoxide];

  programs.nushell.autoloads = [
    (pkgs.runCommand "zoxide-nushell" {} ''
      mkdir -p $out/share/nushell/vendor/autoload
      ${lib.getExe pkgs.zoxide} init nushell > $out/share/nushell/vendor/autoload/20-zoxide.nu
    '')
  ];
}
