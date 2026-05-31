{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "ndu" ''
      set -euo pipefail
      out=$(nix build --dry-run \
        /home/jack/nixos-config#nixosConfigurations.nixos-orion.config.system.build.toplevel \
        --override-input nixpkgs github:NixOS/nixpkgs/nixos-unstable-small 2>&1)

      grep -iE "will be built|will be fetched" <<<"$out" || true
      echo "--- would compile (config-gen noise filtered) ---"
      awk '/will be built:/{f=1;next} /will be fetched/{f=0} f' <<<"$out" \
        | grep '\.drv$' \
        | sed -E 's#.*/[a-z0-9]{32}-##; s#\.drv$##' \
        | grep -vE '^(unit-|X-Restart-Triggers-|system-|user-|etc$|etc-|activate$|activation-|boot\.json|builder\.pl|home-manager|hm_|man-|man$|nixos-(version|help|system)|.*-env$|.*-config.*|.*-completions$|dummy-|extra-|fix-|ensure-|mozilla-native|dbus-1$|issue$|helix-|.*-hook$|.*\.(conf|toml|json|rules|patch|bin|erofs|manpath|service|socket))' \
        | sort -u || true
    '')
  ];
}
