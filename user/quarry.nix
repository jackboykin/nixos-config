{
  config,
  pkgs,
  ...
}: {
  users.users.jack.packages = [pkgs.quarry];

  castle.links = {
    ".config/quarry/exa-api-key" = config.sops.secrets.exa-api-key.path;
    ".config/quarry/typesafe-api-key" = config.sops.secrets.typesafe-api-key.path;
  };

  sops.secrets = {
    exa-api-key.owner = "jack";
    typesafe-api-key.owner = "jack";
  };
}
