{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.collinux.services.headscale;

  acl_file = (pkgs.formats.json {}).generate "acl.json" {
    ssh = [
      {
        src = ["collin@"];
        dst = ["collin@"];
        users = ["autogroup:nonroot" "root"];
        action = "accept";
      }
    ];
  };
in {
  imports = [
    (import ./mkCaddyCfg.nix cfg)
  ];

  config = lib.mkIf cfg.enable {
    services.headscale = {
      enable = true;
      address = cfg.bind_host;
      port = cfg.port;
      settings = {
        server_url = "https://${cfg.root_url}";

        database.type = "sqlite";

        dns = {
          magic_dns = true;
          base_domain = "collinux.tailnet";
          override_local_dns = true;
          nameservers.global = ["9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9"];
        };

        policy.path = acl_file;

        prefixes = {
          "v4" = "100.100.0.0/16";
          allocation = "random";
        };

        # leave tls for caddy to worry about
        tls_cert_path = null;
        tls_key_path = null;

        logtail.enabled = false;
      };
    };

    # make sure headscale can start before tailscale
    systemd.services."headscale" = lib.mkIf config.collinux.system.networking.tailscale.enable {
      after = lib.mkForce ["network.target"];
      before = lib.mkForce ["headscale.target"];
      wants = lib.mkForce ["network.target" "headscale.target"];
    };

    systemd.targets."headscale" = {
      description = "Target represents headscale is running. started by headscale.service";
    };

    environment.systemPackages = [pkgs.headscale];
  };
}
