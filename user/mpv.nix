{
  lib,
  pkgs,
  theme,
  ...
}: let
  inherit (theme) fonts;

  mpv = pkgs.mpv.override {
    youtubeSupport = false;
    scripts = with pkgs.mpvScripts; [uosc mpris];
  };

  toConf = settings:
    lib.concatStringsSep "\n" (lib.mapAttrsToList
      (k: v: "${k}=${
        if lib.isBool v
        then
          if v
          then "yes"
          else "no"
        else toString v
      }")
      settings)
    + "\n";
in {
  users.users.jack.packages = [mpv];

  castle.links.".config/mpv" = pkgs.linkFarm "mpv-config" {
    "mpv.conf" = pkgs.writeText "mpv.conf" (toConf {
      profile = "high-quality";
      geometry = "60%";
      volume = 80;
      volume-max = 180;
      audio-channels = "stereo";
      osd-bar = false;
      osc = false;
      border = false;
      deband = true;
      demuxer-lavf-o = "live_start_index=0";
      force-seekable = true;
      vo = "gpu-next";
      gpu-api = "vulkan";
      hwdec = "vulkan";
      video-sync = "display-resample";
      interpolation = "yes";
      cache = true;
      screenshot-format = "png";
      screenshot-high-bit-depth = true;
      screenshot-png-compression = 3;

      osd-font = fonts.sans.name;
      sub-font = fonts.sans.name;
    });

    "script-opts/uosc.conf" = pkgs.writeText "uosc.conf" (toConf {
      progress = "never";
      controls = "menu,gap,subtitles,audio,video,playlist,chapters,editions,stream-quality,speed,";
    });
  };
}
