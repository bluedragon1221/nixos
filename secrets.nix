let
  inherit ((builtins.fromTOML (builtins.readFile ./hosts.toml)).hosts) mercury ganymede;
in {
  "modules/terminal/nixos/github-ssh-key.age".publicKeys = [mercury.host_pubkey ganymede.host_pubkey];

  "hosts/ganymede/secrets/caddy-env.age".publicKeys = [ganymede.host_pubkey];
  "hosts/ganymede/secrets/williams-psk.age".publicKeys = [ganymede.host_pubkey];
  "hosts/ganymede/secrets/collin-copyparty-password.age".publicKeys = [mercury.host_pubkey ganymede.host_pubkey];
  "hosts/ganymede/secrets/collin-forgejo-password.age".publicKeys = [mercury.host_pubkey ganymede.host_pubkey];

  "hosts/mercury/secrets/ts-key.age".publicKeys = [mercury.host_pubkey];
}
