{pkgs, ...}: {
  programs.mpv = {
    enable = true;

    config = {
      profile = "high-quality";
      geometry = "60%";
      volume = 80;
      volume-max = 180;
      audio-channels = "stereo";
      audio-exclusive = "yes";
      osd-bar = false;
      osc = false;
      border = false;
      deband = true;
      hls-bitrate = "max";
      demuxer-lavf-o = "live_start_index=0";
      force-seekable = true;
      vo = "gpu-next";
      gpu-api = "vulkan";
      hwdec = "vulkan";
      video-sync = "display-resample";
      interpolation="yes";
      cache = true;
      tscale = "oversample";
      dither-depth = "auto";
      screenshot-format = "png";
      screenshot-high-bit-depth = true;
      screenshot-png-compression = 3;
    };

    scripts = with pkgs.mpvScripts; [
      uosc
      mpris
    ];

    scriptOpts = {
      uosc = {
        progress = "never";
        controls = "menu,gap,subtitles,audio,video,playlist,chapters,editions,stream-quality,open-conf,stats,console";
      };
    };
  };
}
