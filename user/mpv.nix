{
  lib,
  pkgs,
  ...
}: let
  inherit (import ../theme.nix) fonts;

  mpv = pkgs.mpv.override {
    mpv-unwrapped = pkgs.mpv-unwrapped.override {ffmpeg = pkgs.ffmpeg-release;};
    youtubeSupport = false;
    scripts = with pkgs.mpvScripts; [uosc mpris];
  };

  pixelClipper = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/Artoriuz/glsl-pixel-clipper/92aa62129d0fd2ce482de52b7aa0fe91e99af1b5/PixelClipper.glsl";
    hash = "sha256-yBzDvsp7MPev6Iaulkc3gB8tgh3CgkYCwAvKgeRTO/w=";
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
      demuxer-lavf-o = "live_start_index=0";
      force-seekable = true;
      vo = "gpu-next";
      gpu-api = "vulkan";
      hwdec = "vulkan";
      cscale = "lanczos";
      dscale = "catmull_rom";
      glsl-shader = pixelClipper;
      video-sync = "display-resample";
      interpolation = "yes";
      cache = true;
      screenshot-format = "png";
      screenshot-png-compression = 3;

      osd-font = fonts.sans.name;
      sub-font = fonts.sans.name;
    });

    "script-opts/uosc.conf" = pkgs.writeText "uosc.conf" (toConf {
      progress = "never";
      controls = "menu,gap,subtitles,audio,video,playlist,chapters,editions,stream-quality,loop-file,speed";
    });
  };
}
