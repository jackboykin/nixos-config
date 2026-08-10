src: final: prev: let
  inherit (prev) lib;

  release = lib.removeSuffix ".git" (lib.trim (builtins.readFile "${src}/RELEASE"));

  lavcSupported = "63";
  lavc = let
    header = builtins.readFile "${src}/libavcodec/version_major.h";
    line = lib.findFirst (lib.hasPrefix "#define LIBAVCODEC_VERSION_MAJOR") null (lib.splitString "\n" header);
  in
    lib.last (lib.splitString " " line);
in {
  ffmpeg-release = assert lib.assertMsg (lavc == lavcSupported) "libavcodec ${lavcSupported} -> ${lavc}";
    prev.stdenv.mkDerivation {
      pname = "ffmpeg";
      version = release;
      inherit src;

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
        spirv-headers
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
        "--glslc=${lib.getExe' prev.buildPackages.shaderc "glslc"}"
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
        remove-references-to -t ${placeholder "out"} -t ${placeholder "lib"} -t ${prev.buildPackages.shaderc.bin} config.h
        grep -q 'define CONFIG_AVGBLUR_VULKAN_FILTER 1' config_components.h || {
          echo "configure disabled spirv_compiler: glslc did not work" >&2
          exit 1
        }
      '';

      meta = {
        homepage = "https://www.ffmpeg.org/";
        description = "Complete, cross-platform solution to record, convert and stream audio and video";
        license = lib.licenses.gpl3Plus;
        platforms = ["x86_64-linux"];
        mainProgram = "ffmpeg";
      };
    };
}
