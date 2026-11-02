{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.caddy;
in
  lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];
    environment.systemPackages = [pkgs.nss.tools]; # required for caddy https stuff

    services.caddy = {
      enable = true;
      environmentFile = cfg.envFile;
      extraConfig = ''
        (internal) {
          @outside not remote_ip 10.100.0.0/24 192.168.50.0/24 10.200.0.0/30
          abort @outside
          tls internal
        }
      '';
    };

    systemd.services.caddy = {
      serviceConfig = {
        RuntimeDirectory = "caddy";
        RuntimeDirectoryMode = "0750";
      };
    };
  }
