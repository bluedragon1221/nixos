{
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.ngircd;
in
  lib.mkIf cfg.enable {
    services.ngircd = {
      enable = true;
      config = ''
        [Global]
          Name = irc.williamsfam.us.com
          Info = Ganymede IRC Chat
          AdminInfo1 = Collin

          Listen = 127.0.0.1
          Ports = ${toString cfg.port}

        [Options]
          PAM = yes
          PAMIsOptional = no

        [Operator]
          Name = collin
          Password =  # users authenticate with PAM
          Mask = *@*
      '';
    };

    users.users.ngircd.extraGroups = ["shadow"];

    security.pam.services.ngircd = {
      unixAuth = true;
    };
  }
