ffmpeg-src: final: prev: {
  # TODO: delete once ffmpeg 9 is released and packaged as ffmpeg_9 in nixpkgs
  ffmpeg-git =
    (prev.ffmpeg_8.override {
      version = "9.0-unstable-${ffmpeg-src.lastModifiedDate}";
      source = ffmpeg-src;
    }).overrideAttrs (old: {
      patches = [];
      # master dropped these libs; configure dies on unknown options
      configureFlags = prev.lib.subtractLists ["--disable-libcelt" "--disable-libshaderc"] old.configureFlags;
      doCheck = false; # `make check` needs a devprogs rule that doesn't resolve on master
    });
}
