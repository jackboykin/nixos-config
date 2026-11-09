pin: final: _: {
  mpv-release = final.llvmStdenv.mkDerivation {
    pname = "mpv";
    inherit (pin) version;
    src = fetchGit {
      inherit (pin) url rev;
      ref = "refs/tags/v${pin.version}";
      shallow = true;
    };

    strictDeps = true;
    mesonBuildType = "release";
    mesonAutoFeatures = "disabled";

    postPatch = ''
      patchShebangs --build TOOLS/*.py
    '';

    nativeBuildInputs = with final; [docutils meson ninja pkg-config python3 wayland-scanner];

    buildInputs = with final; [
      curl
      ffmpeg-release
      lcms2
      libarchive
      libass
      libbluray
      libjpeg
      libplacebo-release
      libuchardet
      libva
      libxkbcommon
      luajit
      pipewire
      vulkan-headers
      vulkan-loader
      wayland
      wayland-protocols
      zimg
      zlib
    ];

    mesonFlags = [
      "-Db_lto=true"
      "-Db_lto_mode=thin"
      "-Dbuild-date=false"
      "-Dgl=disabled"
      "-Dlua=luajit"
      "-Dcplugins=enabled"
      "-Ddmabuf-wayland=enabled"
      "-Diconv=enabled"
      "-Djpeg=enabled"
      "-Dlcms2=enabled"
      "-Dlibarchive=enabled"
      "-Dlibbluray=enabled"
      "-Dlibcurl=enabled"
      "-Dmanpage-build=enabled"
      "-Dpipewire=enabled"
      "-Duchardet=enabled"
      "-Dvaapi=enabled"
      "-Dvaapi-wayland=enabled"
      "-Dvector=enabled"
      "-Dvulkan=enabled"
      "-Dwayland=enabled"
      "-Dzimg=enabled"
      "-Dzlib=enabled"
    ];
  };
}
