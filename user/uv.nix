{pkgs, ...}: let
  toml = pkgs.formats.toml {};
in {
  box.uv = {
    package = pkgs.uv-release;
    use = ["jail"];
    rw = [".cache/uv"];
    fhs = true;
  };

  castle.links.".config/uv/uv.toml" = toml.generate "uv.toml" {
    python-downloads = "never";
    python-preference = "only-system";
  };
}
