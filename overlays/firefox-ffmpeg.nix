final: prev: {
  wrapFirefox = prev.wrapFirefox.override {ffmpeg_7 = prev.ffmpeg;};
}
