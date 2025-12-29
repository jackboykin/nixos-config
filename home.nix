{ _config, pkgs, ... }:

{
  home.username = "jack";
  home.homeDirectory = "/home/jack";
  home.stateVersion = "25.11";

  # General packages
  home.packages = with pkgs; [
    spotify
    kdePackages.kate
    remmina
    jellyfin-media-player
    antigravity
  ];

  programs.mpv = {
    enable = true;

    # mpv.conf
    config = {
      profile = "high-quality";

      # UI and Window settings
      geometry = "60%";
      volume = 80;
      volume-max = 180;
      audio-channels = "auto-safe";
      audio-exclusive = "yes";
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
      hwdec = "vulkan";
      video-sync = "display-resample";
      cache = true;

      # Screenshots
      screenshot-format = "png";
      screenshot-high-bit-depth = true;
      screenshot-png-compression = 3;
    };

    # Scripts
    scripts = with pkgs.mpvScripts; [
      uosc
      mpris
    ];
  };

  programs.git = {
  enable = true;
  settings = {
    user = {
      name = "Jack Boykin";
      email = "jtboykin.jb@gmail.com";
    };
  };
};

  # uosc options
  home.file.".config/mpv/script-opts/uosc.conf".text = ''
    progress_bar=unfocused
    controls=menu,gap,subtitles,audio,video,playlist,chapters,editions,stream-quality,open-conf,stats,console
  '';

  # Home Manager Manage
  programs.home-manager.enable = true;
}
