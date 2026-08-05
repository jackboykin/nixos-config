ffmpeg-master: final: prev: let
  inherit (prev) lib;

  d = ffmpeg-master.lastModifiedDate;
  date = "${lib.substring 0 4 d}-${lib.substring 4 2 d}-${lib.substring 6 2 d}";

  lavcSupported = "63";
  lavc = let
    header = builtins.readFile "${ffmpeg-master}/libavcodec/version_major.h";
    line = lib.findFirst (lib.hasPrefix "#define LIBAVCODEC_VERSION_MAJOR") null (lib.splitString "\n" header);
  in
    lib.last (lib.splitString " " line);
in {
  ffmpeg-master = assert lib.assertMsg (lavc == lavcSupported) "libavcodec ${lavcSupported} -> ${lavc}";
    prev.stdenv.mkDerivation {
      pname = "ffmpeg-master";
      version = date;
      src = ffmpeg-master;

      outputs = ["out" "lib"];

      strictDeps = true;
      enableParallelBuilding = true;

      nativeBuildInputs = with prev; [nasm pkg-config removeReferencesTo];

      buildInputs = with prev; [
        dav1d
        lame
        libdrm
        libopus
        libva
        libvorbis
        libwebp
        libxml2
        openssl
        soxr
        svt-av1
        vulkan-headers
        vulkan-loader
        x264
        x265
        zimg
        zlib
      ];

      configurePlatforms = [];
      setOutputFlags = false;
      configureFlags = [
        "--prefix=${placeholder "out"}"
        "--libdir=${placeholder "lib"}/lib"
        "--shlibdir=${placeholder "lib"}/lib"
        "--incdir=${placeholder "out"}/include"
        "--datadir=${placeholder "out"}/share/ffmpeg"
        "--cc=${prev.stdenv.cc.targetPrefix}cc"

        "--cpu=native"
        "--disable-runtime-cpudetect"
        "--disable-debug"
        "--disable-doc"

        "--disable-autodetect"
        "--disable-avdevice"
        "--disable-iconv"

        "--enable-gpl"
        "--enable-version3"
        "--enable-shared"
        "--disable-static"
        "--disable-ffplay"

        "--enable-vulkan"
        "--enable-vaapi"
        "--enable-libdrm"
        "--enable-libdav1d"
        "--enable-libopus"
        "--enable-libsvtav1"
        "--enable-libx264"
        "--enable-libx265"
        "--enable-zlib"

        "--enable-openssl"
        "--enable-libmp3lame"
        "--enable-libvorbis"
        "--enable-libwebp"

        "--enable-libxml2"
        "--enable-libsoxr"
        "--enable-libzimg"
      ];

      postConfigure = ''
        remove-references-to -t ${placeholder "out"} -t ${placeholder "lib"} config.h
      '';

      meta = {
        homepage = "https://www.ffmpeg.org/";
        description = "FFmpeg master, trimmed to firefox's decode path and local transcoding";
        license = lib.licenses.gpl3Plus;
        platforms = ["x86_64-linux"];
        mainProgram = "ffmpeg";
      };
    };
}
