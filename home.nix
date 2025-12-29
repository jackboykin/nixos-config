{ _config, pkgs, ... }:

{
  home.username = "jack";
  home.homeDirectory = "/home/jack";
  home.stateVersion = "25.11";

  # General packages here
  home.packages = with pkgs; [
    spotify
    kdePackages.kate
    remmina
  ];

  programs.mpv = {
    enable = true;

    # mpv.conf
    config = {
      profile = "high-quality";

      scripts = "~/.config/mpv/scripts";

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

  # symlinks
  home.file = {
    ".config/mpv/scripts/uosc".source = "${pkgs.mpvScripts.uosc}/share/mpv/scripts/uosc";
    ".config/mpv/scripts/mpris.lua".source = "${pkgs.mpvScripts.mpris}/share/mpv/scripts/mpris.lua";
    ".config/mpv/fonts".source = "${pkgs.mpvScripts.uosc}/share/mpv/fonts";

    ".config/mpv/script-opts/uosc.conf".text = ''
      progress_bar=unfocused
      controls=menu,gap,subtitles,audio,video,playlist,chapters,editions,stream-quality,open-conf,stats,console
    '';
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
