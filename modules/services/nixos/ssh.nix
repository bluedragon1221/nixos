{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.networking.sshd;
in
  lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  }
