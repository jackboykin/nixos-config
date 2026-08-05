inputs: final: prev: {
  firefox-nightly = (prev.wrapFirefox.override {ffmpeg_8 = final.ffmpeg-master;})
  inputs.firefox-nightly.packages.${prev.stdenv.hostPlatform.system}.firefox-nightly-bin.unwrapped
  {};
}
