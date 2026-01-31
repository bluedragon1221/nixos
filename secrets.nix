let
  inherit ((builtins.fromTOML (builtins.readFile ./hosts.toml)).hosts) mercury ganymede jupiter;
in {
  "caddy-env.age".publicKeys = [ganymede.host_pubkey];
  "tsnsrv-authkey.age".publicKeys = [ganymede.host_pubkey mercury.host_pubkey];
  "williams-psk.age".publicKeys = [ganymede.host_pubkey];
  "github-ssh-key.age".publicKeys = [mercury.host_pubkey jupiter.host_pubkey];

  "collin-copyparty-password.age".publicKeys = [mercury.host_pubkey ganymede.host_pubkey];
}
