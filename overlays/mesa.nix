src: final: prev: let
  inherit (prev) lib;

  retuned = ["gallium-drivers" "vulkan-drivers" "vulkan-layers" "tools" "teflon" "freedreno-kmds" "amdgpu-virtio" "intel-rt" "install-precomp-compiler"];
  untouched = flag: !lib.any (k: lib.hasPrefix "-D${k}=" flag) retuned;
in {
  mesa-main = (prev.mesa.override {stdenv = final.llvmStdenv;}).overrideAttrs (o: {
    version = lib.trim (builtins.readFile "${src}/VERSION");
    inherit src;

    outputs = lib.remove "spirv2dxil" o.outputs;
    depsBuildBuild = lib.remove prev.buildPackages.stdenv.cc o.depsBuildBuild;

    mesonFlags =
      lib.filter untouched o.mesonFlags
      ++ [
        "-Dgallium-drivers=radeonsi,llvmpipe,zink"
        "-Dvulkan-drivers=amd,swrast"
        "-Dvulkan-layers=device-select"
      ];
  });
}
