final: prev: {
  kdePackages = prev.kdePackages.overrideScope (_: kp: let
    drop = pkg:
      pkg.overrideAttrs (o: {
        buildInputs = builtins.filter (d: (d.pname or "") != "qtwebengine") o.buildInputs;
      });
  in {
    kdeplasma-addons = drop kp.kdeplasma-addons;
    libksysguard = drop kp.libksysguard;
  });
}
