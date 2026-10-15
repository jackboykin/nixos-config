{pkgs, ...}: let
  binutils = pkgs.binutils-unwrapped;
  perf = pkgs.perf.overrideAttrs (old: {
    postPatch =
      old.postPatch
      + ''
        substituteInPlace util/disasm.c --replace-fail '?: "objdump"' '?: "${binutils}/bin/objdump"'
        substituteInPlace util/addr2line.c --replace-fail '?: "addr2line"' '?: "${binutils}/bin/addr2line"'
      '';
    preFixup = "";
  });
in {
  security.wrappers.perf = {
    owner = "root";
    group = "root";
    source = "${perf}/bin/perf";
    capabilities = "cap_perfmon,cap_syslog+ep";
  };
}
