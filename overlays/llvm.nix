_: prev: let
  llvm = prev.llvmPackages_latest;
in {
  llvmStdenv = prev.overrideCC llvm.stdenv (llvm.clang.override {inherit (llvm) bintools;});
}
