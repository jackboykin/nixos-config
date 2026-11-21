{pkgs, ...}: {
  box.spotify = {
    package = pkgs.spotify;
    use = ["wayland" "gtk" "gpu" "audio"];
    rw = [".cache/spotify" ".config/spotify"];
    bus = [
      "own=org.mpris.MediaPlayer2.spotify"
      "talk=org.freedesktop.Notifications"
    ];
    net = "own";
  };
}
