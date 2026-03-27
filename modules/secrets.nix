_: {
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets = {
      user-password = {
        neededForUsers = true;
      };
    };
  };
}
