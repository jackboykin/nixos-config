{
  config,
  username,
  ...
}: {
  programs.nh = {
    enable = true;
    flake = "/home/${username}/nixos-config";
  };

  systemd.services.nix-prune = {
    startAt = "daily";
    path = [config.nix.package];
    script = ''
      recent=4 series=2
      p=/nix/var/nix/profiles/system
      declare -A seen; del=(); n=0
      for id in $(ls -d $p-*-link | grep -o '[0-9]*-link' | cut -d- -f1 | sort -rn); do
        g=$p-$id-link
        v=$(ls $g/kernel-modules/lib/modules); s=''${v%.*}
        if (( n++ < recent )) || [[ -z ''${seen[$s]:-} && ''${#seen[@]} -lt $series ]] \
           || [[ $g -ef $p || $g -ef /run/booted-system ]]; then
          echo "keep $id linux-$v"
        else
          del+=("$id")
        fi
        seen[$s]=1
      done
      (( ''${#del[@]} )) && nix-env -p $p --delete-generations "''${del[@]}"
      $p/bin/switch-to-configuration boot
      nix-collect-garbage
      nix-store --optimise
    '';
  };
  systemd.timers.nix-prune.timerConfig.Persistent = true;

  nix = {
    channel.enable = false;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "cgroups"
        "auto-allocate-uids"
      ];
      use-cgroups = true;
      auto-allocate-uids = true;
      allowed-users = [
        "root"
        "@wheel"
      ];
      flake-registry = "";
      use-xdg-base-directories = true;
      max-jobs = 2;
      cores = 16;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };
}
