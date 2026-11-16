{
  config,
  lib,
  pkgs,
  utils,
  ...
}: let
  root = config.fileSystems."/".device;
  diagnose = false;
  esp = config.fileSystems."/boot".device;
in {
  # converts / from ext4 to bcachefs in place on first boot; drop once / is bcachefs
  boot.initrd.availableKernelModules = [
    "ext4"
    "vfat"
    "nls_cp437"
    "nls_iso8859_1"
  ];

  boot.initrd.systemd = {
    initrdBin = with pkgs; [
      attr
      diffutils
      e2fsprogs
      findutils
      gawk
      gnugrep
      gzip
      util-linux
    ];
    extraBin.bootctl = "${config.boot.initrd.systemd.package}/bin/bootctl";

    services.convert-root = {
      description = "Convert / from ext4 to bcachefs";
      requiredBy = ["sysroot.mount"];
      before = [
        "sysroot.mount"
        "unlock-bcachefs-${utils.escapeSystemdPath "/"}.service"
      ];
      requires = ["${utils.escapeSystemdPath root}.device"];
      after = ["${utils.escapeSystemdPath root}.device"];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "infinity";
        StandardOutput = "journal+console";
        StandardError = "journal+console";
      };
      script = ''
        set -eEuo pipefail
        diagnose_flag=${lib.boolToString diagnose}
        dev=${root}
        [ "$(blkid -o value -s TYPE "$dev")" = ext4 ] || exit 0

        w=/run/convert-root
        mkdir -p $w/esp $w/old $w/new
        loader() {
          tail -c +5 /sys/firmware/efi/efivars/$1-4a67b082-0a4c-41cf-b6c7-440b29bb8c4f | tr -d '\0' | grep -o 'nixos-generation-[0-9]*-[a-z0-9]*\.efi'
        }
        fallback() {
          [ "$BASHPID" = "$$" ] || exit 1
          trap - ERR
          echo "stopped before the point of no return; ext4 is intact"
          umount $w/new $w/old 2>/dev/null || true
          if mount -t ext4 "$dev" $w/old 2>/dev/null; then
            rm -f $w/old/bcachefs
            umount $w/old
          fi
          selected=$(loader LoaderEntrySelected) || true
          n=''${selected#nixos-generation-}
          n=''${n%%-*}
          prev=$(loader LoaderEntryDefault) || true
          [ -n "$prev" ] && [ "$prev" != "$selected" ] ||
            prev=$(loader LoaderEntries | awk -F- -v n="$n" '$3 < n {print $3, $0}' | sort -n | tail -1 | cut -d' ' -f2) || true
          [ -n "$prev" ] || { echo "no earlier boot entry to fall back to"; exit 1; }
          echo "booting $prev by default from now on"
          bootctl set-default "$prev"
          sync
          umount $w/esp 2>/dev/null || true
          systemctl --no-block start reboot.target
          exit 1
        }
        trap fallback ERR

        if mount -t vfat ${esp} $w/esp; then
          exec > >(tee -a $w/esp/convert-root.log) 2>&1
        fi
        echo "== $(date -u) converting $dev to bcachefs"

        manifest() {
          (
            cd "$1"
            find . -xdev -mindepth 1 ! -path ./lost+found ! -path './lost+found/*' ! -path ./bcachefs ! -path ./old_migrated_filesystem \
              \( -type d -printf '%y %m %U %G - %n %T@ %p\t\n' -o -type l -printf '%y %m %U %G %s - %T@ %p\t%l\n' -o -printf '%y %m %U %G %s %n %T@ %p\t%l\n' \) | LC_ALL=C sort > "$2.meta"
            getfattr -R -h -d -m - -e hex . 2>/dev/null | awk '/^# file: /{f=substr($0,9); next} /=/{print f "\t" $0}' | LC_ALL=C sort > "$2.xattr"
            [ "$3" = data ] || exit 0
            find . -xdev -type f ! -path './lost+found/*' ! -path ./bcachefs ! -path ./old_migrated_filesystem -print0 |
              xargs -0 -P16 -n256 sha256sum | LC_ALL=C sort -k2 > "$2.sha"
          )
          echo "$(wc -l < "$2.meta") entries in $1"
        }
        diagnose() {
          trap - ERR
          set +e
          d=$w/esp/convert-root-diag
          rm -rf $d
          mkdir -p $d
          echo "== diagnosing at sector $sb, output in /boot/convert-root-diag"
          mount -t bcachefs -o "sb=$sb,ro" "$dev" $w/new || { echo "offset mount failed"; return; }
          for pass in 1 2 3; do
            (cd $w/new && find . -xdev -mindepth 1 ! -path ./old_migrated_filesystem -printf '%y %i %n %p\n' 2> $d/find-errors-$pass.txt | LC_ALL=C sort -k4) > $w/mid.ino
            echo "pass $pass: $(wc -l < $d/find-errors-$pass.txt) find errors, $(wc -l < $w/mid.ino) entries listed (ext4 had $(wc -l < $w/pre.ino))"
            [ $pass = 2 ] && echo 3 > /proc/sys/vm/drop_caches
          done
          cat $d/find-errors-*.txt | sort -u > $d/find-errors.txt
          grep -o "'[^']*'" $d/find-errors.txt | tr -d "'" | head -40 | while IFS= read -r p; do
            {
              echo "== retries of $p"
              for i in 1 2 3 4 5 6 7 8; do stat -c "try $i: %F %i" "$w/new/$p" 2>&1; done
            } >> $d/entries.txt 2>&1
            parent=$(dirname "$p")
            name=$(basename "$p")
            {
              echo "== $p"
              echo "ext4: $(grep -F " $p" $w/pre.ino | head -3)"
              echo "ext4 parent: $(grep -F " $parent" $w/pre.ino | grep -E " $parent\$" | head -1)"
              pino=$(stat -c %i "$w/new/$parent")
              echo "bcachefs parent: inode $pino"
              echo "readdir: $(cd "$w/new/$parent" && ls -fi | grep -E " $name\$")"
              dino=$(cd "$w/new/$parent" && ls -fi | awk -v n="$name" '$2 == n {print $1}')
              stat "$w/new/$p" 2>&1
              bcachefs list -b dirents -s "$pino:0" -e "$((pino + 1)):0" $w/new 2>&1 | grep -F -- "$name"
              [ -n "$dino" ] && bcachefs list -b inodes -s "0:$dino" -e "0:$((dino + 1))" $w/new 2>&1 | head -5
              echo
            } >> $d/entries.txt 2>&1
          done
          awk '{print $4}' $w/pre.ino > $w/pre.paths
          awk '{print $4}' $w/mid.ino > $w/mid.paths
          diff $w/pre.paths $w/mid.paths | head -2000 > $d/path-diff.txt
          echo "$(grep -c '^<' $d/path-diff.txt) paths only on ext4, $(grep -c '^>' $d/path-diff.txt) only on bcachefs (first 2000 diff lines)"
          manifest $w/new $w/mid meta > /dev/null 2> $d/manifest-errors.txt
          diff $w/pre.meta $w/mid.meta | head -400 > $d/meta-diff.txt
          echo "$(grep -c '^<' $d/meta-diff.txt) metadata lines differ (first 400 diff lines)"
          dmesg | grep -i bcachefs | tail -400 > $d/dmesg.txt
          umount $w/new
          bcachefs fsck -n -o "sb=$sb" "$dev" > $d/fsck.txt 2>&1
          echo "full fsck exit $?: $(grep -c -i -E 'error|fix|mismatch|missing|bad' $d/fsck.txt) suspicious lines"
          tail -c 20000 $d/fsck.txt > $d/fsck-tail.txt
          gzip -f $d/fsck.txt
          cp $w/migrate.log $d/
          sync
          set -e
        }
        same() {
          for k in $3; do
            diff -q "$1.$k" "$2.$k" > /dev/null || { echo "$k differs:"; diff "$1.$k" "$2.$k" | head -20; return 1; }
          done
        }

        e2fsck -fn "$dev"
        mount -t ext4 "$dev" $w/old
        rm -f $w/old/var/lib/swapfile $w/old/bcachefs
        if $diagnose_flag; then
          manifest $w/old $w/pre meta
          (cd $w/old && find . -xdev -mindepth 1 ! -path ./bcachefs -printf '%y %i %n %p\n' | LC_ALL=C sort -k4) > $w/pre.ino
        else
          manifest $w/old $w/pre data
        fi
        too_big=$(awk -F'\t' '{i=index($2,"="); if (i - 1 + (length($2) - i - 2) / 2 > 1990) print}' < $w/pre.xattr)
        [ -z "$too_big" ] || { echo "xattrs too large for bcachefs:"; echo "$too_big"; false; }
        echo "$(wc -l < $w/pre.meta) entries"

        bcachefs migrate -f $w/old | tee $w/migrate.log
        sb=$(grep -o 'sb=[0-9]*' $w/migrate.log | tail -1 | cut -d= -f2)
        [ -n "$sb" ]
        umount $w/old

        if $diagnose_flag; then
          diagnose
          fallback
        fi

        mount -t bcachefs -o "sb=$sb,ro" "$dev" $w/new
        manifest $w/new $w/mid data
        same $w/pre $w/mid "meta xattr sha"
        umount $w/new
        echo "bcachefs at sector $sb matches ext4 file for file"

        trap 'echo "failed after the point of no return; / is a half-finished bcachefs"' ERR
        bcachefs migrate-superblock -d "$dev" -o "$sb"
        bcachefs fsck -n "$dev"
        mount -t bcachefs "$dev" $w/new
        rm $w/new/old_migrated_filesystem
        manifest $w/new $w/post meta
        same $w/pre $w/post "meta xattr"
        umount $w/new
        echo "== $(date -u) done"
        umount $w/esp 2>/dev/null || true
      '';
    };
  };
}
