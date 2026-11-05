pin: final: prev: {
  libplacebo-release = final.llvmStdenv.mkDerivation {
    pname = "libplacebo";
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
      substituteInPlace meson.build --replace-fail 'python_env.append' '#'
    '';

    nativeBuildInputs = with final; [meson ninja pkg-config python3Packages.jinja2];

    buildInputs = with final; [
      fast-float
      lcms2
      libdovi
      shaderc
      vulkan-headers
      vulkan-loader
      xxhash
    ];

    mesonFlags = [
      "-Db_lto=true"
      "-Db_lto_mode=thin"
      "-Ddemos=false"
      "-Dvulkan-registry=${final.vulkan-headers}/share/vulkan/registry/vk.xml"
      "-Ddovi=enabled"
      "-Dlcms=enabled"
      "-Dlibdovi=enabled"
      "-Dshaderc=enabled"
      "-Dvk-proc-addr=enabled"
      "-Dvulkan=enabled"
      "-Dxxhash=enabled"
    ];

    meta = {
      homepage = "https://code.videolan.org/videolan/libplacebo";
      description = "GPU-accelerated video/image rendering primitives";
      license = prev.lib.licenses.lgpl21Plus;
      platforms = ["x86_64-linux"];
    };
  };
}
