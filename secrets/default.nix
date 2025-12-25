{
  age = {
    identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      "caddy-tailscale-authkey".file = ./caddy-tailscale-authkey.age;
    };
  };
}
