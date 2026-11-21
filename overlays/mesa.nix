pin: final: prev: let
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

  llvm = final.llvmPackages_latest;

  mesa = final.mesa.override {
    stdenv = final.llvmStdenv;
    llvmPackages = llvm;
    mesa-libclc = null;
    spirv-llvm-translator = null;
  };
in {
  mesa-orion = mesa.overrideAttrs (o: {
    inherit (pin) version;
    src = final.fetchurl {inherit (pin) url hash;};

    outputs = lib.subtractLists ["spirv2dxil" "opencl" "cross_tools"] o.outputs;
    depsBuildBuild = lib.remove final.buildPackages.stdenv.cc o.depsBuildBuild;
    buildInputs = lib.subtractLists [llvm.clang llvm.clang-unwrapped llvm.libllvm] o.buildInputs;
    preConfigure = "";

    mesonFlags =
      lib.filter untouched o.mesonFlags
      ++ [
        "-Dllvm=disabled"
        "-Dgallium-drivers=radeonsi,zink"
        "-Dvulkan-drivers=amd"
        "-Dvulkan-layers=device-select"
      ];

    postInstall = "";
    postFixup = lib.replaceStrings [" $opencl/lib/libRusticlOpenCL.so"] [""] o.postFixup;
  });
}
