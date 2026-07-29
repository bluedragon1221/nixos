{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.system.network.dns;
in
  lib.mkIf cfg.areYouAServer {
    networking = {
      nameservers = ["127.0.0.1"];
      resolvconf.enable = lib.mkForce true; # we disabled this earlier
    };
    services.resolved.enable = false;

    services.unbound = {
      enable = true;
      settings.server = {
        interface = ["0.0.0.0"];
        port = 53;
        access-control = [
          "127.0.0.0/8 allow"
          "10.100.0.0/24 allow"
          "0.0.0.0/0 refuse"
        ];

        local-zone = [''"ganymede." redirect''];
        local-data = [''"ganymede. IN A 10.100.0.1"''];
      };
    };
  }
