final: _: let
  llvm = final.llvmPackages_latest;
in {
  llvmStdenv = final.overrideCC llvm.stdenv (llvm.clang.override {inherit (llvm) bintools;});
}
