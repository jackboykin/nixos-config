{pkgs, ...}: let
  perf = pkgs.perf.override {makeWrapper = pkgs.makeBinaryWrapper;};
in {
  security.wrappers.perf = {
    owner = "root";
    group = "root";
    source = "${perf}/bin/perf";
    capabilities = "cap_perfmon,cap_syslog+ep";
  };
}
