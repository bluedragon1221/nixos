{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.ngircd;
in
  lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optional cfg.public cfg.port;

    services.ngircd = {
      enable = true;
      config = ''
        [Global]
          Name = williamsfam.us.com
          Info = Ganymede IRC Chat
          AdminInfo1 = Collin

          Listen = ${
          if cfg.public
          then "0.0.0.0"
          else "127.0.0.1"
        }
          Ports = ${toString cfg.port}

        [Channel]
          Name = #general
          AutoJoin = yes

        [Options]
          RequireAuth = no
          Ident = no
          AllowedHosts = *
          PAM = no
      '';
    };
  }
