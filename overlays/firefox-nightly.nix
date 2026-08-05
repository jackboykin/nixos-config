inputs: final: prev: {
  # nightly dlopens libavcodec.so.63; the wrapper still pins ffmpeg_8 for >=146
  firefox-nightly = (prev.wrapFirefox.override {ffmpeg_8 = final.ffmpeg-master;})
  inputs.firefox-nightly.packages.${prev.stdenv.hostPlatform.system}.firefox-nightly-bin.unwrapped
  {};
}
