pin: final: prev: {
  linux-firmware = prev.linux-firmware.overrideAttrs {
    inherit (pin) version;
    src = (final.fetchzip {inherit (pin) url hash;}).overrideAttrs {outputHashMode = "git";};
  };
}
