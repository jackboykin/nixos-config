inputs: final: prev: {
  # rewrap the flake's nightly with ffmpeg-git so the dlopen path serves
  # libavcodec.so.63; the flake's own wrapper drv is never built (lazy)
  firefox-nightly = (prev.wrapFirefox.override {ffmpeg_7 = final.ffmpeg-git;})
  inputs.firefox-nightly.packages.${prev.stdenv.hostPlatform.system}.firefox-nightly-bin.unwrapped
  {};
}
