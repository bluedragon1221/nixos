let
  inherit ((builtins.fromTOML (builtins.readFile ./hosts.toml)).hosts) mercury ganymede jupiter;
in {
  "hosts/ganymede/caddy-env.age".publicKeys = [ganymede.host_pubkey];
  "hosts/ganymede/williams-psk.age".publicKeys = [ganymede.host_pubkey];
  "modules/terminal/nixos/github-ssh-key.age".publicKeys = [mercury.host_pubkey jupiter.host_pubkey ganymede.host_pubkey];

  "hosts/ganymede/collin-copyparty-password.age".publicKeys = [mercury.host_pubkey ganymede.host_pubkey];
  "hosts/ganymede/collin-forgejo-password.age".publicKeys = [mercury.host_pubkey ganymede.host_pubkey];
}
