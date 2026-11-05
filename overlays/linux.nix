pin: final: prev: {
  linux_testing = prev.linux_testing.override {
    argsOverride = {
      inherit (pin) version;
      modDirVersion = prev.lib.versions.pad 3 pin.version;
      src = (final.fetchzip {inherit (pin) url hash;}).overrideAttrs {outputHashMode = "git";};
    };
  };
}
