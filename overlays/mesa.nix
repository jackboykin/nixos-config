src: final: prev: let
  inherit (prev) lib;

  retuned = [
    "gallium-drivers"
    "vulkan-drivers"
    "vulkan-layers"
    "tools"
    "teflon"
    "freedreno-kmds"
    "amdgpu-virtio"
    "intel-rt"
    "install-precomp-compiler"
    "gallium-rusticl"
    "gallium-rusticl-enable-drivers"
    "install-mesa-clc"
    "clang-libdir"
  ];
  untouched = flag: !lib.any (k: lib.hasPrefix "-D${k}=" flag) retuned;

  mesa = final.mesa.override {
    stdenv = final.llvmStdenv;
    llvmPackages = final.llvmPackages_latest;
    spirv-llvm-translator = null;
  };
in {
  mesa-main = mesa.overrideAttrs (o: {
    version = lib.trim (builtins.readFile "${src}/VERSION");
    inherit src;

    outputs = lib.subtractLists ["spirv2dxil" "opencl" "cross_tools"] o.outputs;
    depsBuildBuild = lib.remove final.buildPackages.stdenv.cc o.depsBuildBuild;

    mesonFlags =
      lib.filter untouched o.mesonFlags
      ++ [
        "-Dgallium-drivers=radeonsi,llvmpipe,zink"
        "-Dvulkan-drivers=amd,swrast"
        "-Dvulkan-layers=device-select"
      ];

    postInstall = "";
    postFixup = lib.replaceStrings [" $opencl/lib/libRusticlOpenCL.so"] [""] o.postFixup;
  });
}
