_: {
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;

    # System age key for early-boot secrets
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets = {
      user-password = {
        neededForUsers = true;
      };
      brave-api-key = {
        owner = "jack";
      };
    };
  };
}
