{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.agate;
in
  lib.mkIf cfg.enable {
    services.agate = {
      enable = true;
      addresses = [
        "0.0.0.0:1965"
      ];
      hostnames = [cfg.publicUrl];

      onlyTls_1_3 = true;

      contentDir = "/media/public/gmi";
    };

    networking.firewall.allowedTCPPorts = [1965];
  }
