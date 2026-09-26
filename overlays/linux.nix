pin: final: prev: {
  linux_testing = prev.linux_testing.override {
    argsOverride = {
      inherit (pin) version;
      modDirVersion = prev.lib.versions.pad 3 pin.version;
      src = (prev.fetchzip {inherit (pin) url hash;}).overrideAttrs {outputHashMode = "git";};
    };
  };
}
