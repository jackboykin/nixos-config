pin: final: _: {
  mesa-orion = final.llvmStdenv.mkDerivation {
    pname = "mesa";
    inherit (pin) version;

    src = final.fetchurl {inherit (pin) url hash;};

    strictDeps = true;
    separateDebugInfo = true;
    mesonAutoFeatures = "disabled";

    postPatch = ''
      patchShebangs .
    '';

    nativeBuildInputs = with final; [
      bison
      flex
      (lib.getBin glslang)
      meson
      ninja
      pkg-config
      (python3.withPackages (p: [p.mako p.packaging p.ply p.pycparser p.pyyaml]))
      wayland-scanner
    ];

    buildInputs = with final; [
      elfutils
      expat
      libdisplay-info
      libdrm
      libgbm
      libglvnd
      libva-minimal
      libx11
      libxcb
      libxcb-keysyms
      libxext
      libxfixes
      libxrandr
      libxshmfence
      libxxf86vm
      lm_sensors
      udev
      wayland
      wayland-protocols
      xorgproto
      zlib
      zstd
    ];

    mesonFlags = [
      "--sysconfdir=/etc"
      "-Db_ndebug=true"
      "-Dplatforms=x11,wayland"
      "-Dgallium-drivers=radeonsi,zink"
      "-Dvulkan-drivers=amd"
      "-Dvulkan-layers=device-select"
      "-Dvideo-codecs=all"
      "-Dgallium-extra-hud=true"
      "-Dlibgbm-external=true"
      "-Dallow-kcmp=enabled"
      "-Ddisplay-info=enabled"
      "-Degl=enabled"
      "-Dexpat=enabled"
      "-Dgallium-va=enabled"
      "-Dgbm=enabled"
      "-Dgles1=enabled"
      "-Dgles2=enabled"
      "-Dglvnd=enabled"
      "-Dlmsensors=enabled"
      "-Dshader-cache=enabled"
      "-Dxlib-lease=enabled"
      "-Dxmlconfig=enabled"
      "-Dzlib=enabled"
      "-Dzstd=enabled"
    ];

    postFixup = ''
      substituteInPlace $out/share/glvnd/egl_vendor.d/50_mesa.json --replace-fail '"libEGL_' '"'"$out/lib/libEGL_"
      substituteInPlace $out/share/vulkan/implicit_layer.d/*.json --replace-fail '"libVkLayer_' '"'"$out/lib/libVkLayer_"
      rm -r $out/include $out/lib/pkgconfig
      patchelf --add-rpath ${final.vulkan-loader}/lib $out/lib/libgallium-*.so
    '';
  };
}
