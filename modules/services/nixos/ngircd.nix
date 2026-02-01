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
          Name = Ganymede IRC Chat

          Listen = 0.0.0.0
          Port = ${cfg.port}

          PAM = yes
          PAMIsOptional = no

        [Operators]
          Name = collin
          Password =  # users authenticate with PAM
          Mask = *@*
      '';
    };
  }
