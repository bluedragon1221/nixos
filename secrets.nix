let
  inherit ((builtins.fromTOML (builtins.readFile ./hosts.toml)).hosts) mercury ganymede;
in {
  "modules/terminal/nixos/github-ssh-key.age".publicKeys = [mercury.host_pubkey ganymede.host_pubkey];

  "hosts/ganymede/secrets/caddy-env.age".publicKeys = [mercury.host_pubkey ganymede.host_pubkey];
  "hosts/ganymede/secrets/caddy-root-ca.key.age".publicKeys = [mercury.host_pubkey ganymede.host_pubkey];
  "hosts/ganymede/secrets/williams-psk.age".publicKeys = [mercury.host_pubkey ganymede.host_pubkey];

  "hosts/mercury/secrets/wg-privkey.age".publicKeys = [mercury.host_pubkey];
  "hosts/ganymede/secrets/wg-privkey.age".publicKeys = [mercury.host_pubkey ganymede.host_pubkey];
}
