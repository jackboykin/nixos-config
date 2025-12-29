{ _config, pkgs, ... }:

{
  home.username = "jack";
  home.homeDirectory = "/home/jack";
  home.stateVersion = "25.11";

  # General packages here
  home.packages = with pkgs; [
    #jellyfin-media-player
    spotify
    kdePackages.kate
  ];

  programs.mpv = {
    enable = true;

    # This block replaces your mpv.conf
    config = {
      profile = "high-quality";

      # UI and Window settings
      geometry = "60%";
      volume = 80;
      volume-max = 180;
      audio-channels = "auto-safe";
      osd-bar = false;
      osc = false;
      border = false;

      # Video and Playback
      deband = false;
      hls-bitrate = "max";
      demuxer-lavf-o = "live_start_index=0";
      force-seekable = true;

      # Graphics API and Rendering
      vo = "gpu-next";
      gpu-api = "vulkan";
      hwdec = "auto-safe";
      video-sync = "display-resample";
      cache = true;

      # Screenshots
      screenshot-format = "png";
      screenshot-high-bit-depth = true;
      screenshot-png-compression = 3;
    };

    # Keeping your scripts from earlier
    scripts = with pkgs.mpvScripts; [
      uosc
      mpris
    ];
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
