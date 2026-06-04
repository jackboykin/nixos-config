{pkgs, ...}: {
  home.packages = [
    (pkgs.writers.writeNuBin "ndu" ''
      let target = "/home/jack/nixos-config#nixosConfigurations.nixos-orion.config.system.build.toplevel"

      let noise = '^(unit-|X-Restart-Triggers-|system-|user-|etc$|etc-|activate$|activation-|boot\.json|builder\.pl|home-manager|hm_|man-|man$|nixos-(version|help|system)|.*-env$|.*-config.*|.*-completions$|dummy-|extra-|fix-|ensure-|mozilla-native|dbus-1$|issue$|helix-|.*-hook$|.*\.(conf|toml|json|rules|patch|bin|erofs|manpath|service|socket))'

      let plan = (
        nix build --dry-run $target --override-input nixpkgs github:NixOS/nixpkgs/nixos-unstable-small
        | complete | get stderr | lines
      )

      print ($plan | where {|l| $l =~ '(?i)will be (built|fetched)' } | str join (char newline))
      print "--- would compile (config-gen noise filtered) ---"

      $plan
      | skip until {|l| $l =~ 'will be built' }
      | skip 1
      | take until {|l| $l =~ 'will be fetched' }
      | str trim
      | where {|l| $l | str ends-with '.drv' }
      | str replace -r '.*/[a-z0-9]{32}-' ""
      | str replace -r '\.drv$' ""
      | where {|l| $l !~ $noise }
      | uniq
      | sort
      | str join (char newline)
      | print
    '')
  ];
}
