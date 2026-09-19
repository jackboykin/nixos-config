{pkgs, ...}: {
  security.wrappers.perf = {
    owner = "root";
    group = "root";
    source = "${pkgs.perf}/bin/perf";
    capabilities = "cap_perfmon,cap_syslog+ep";
  };
}
