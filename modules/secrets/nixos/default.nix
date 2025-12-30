{
  inputs,
  config,
  ...
}: let
  cfg = config.collinux.secrets;
in {
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age = {
    identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secretsDir = "/run/secrets.d";
    secrets = cfg;
  };
}
