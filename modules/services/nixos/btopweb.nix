{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.collinux.services.btopweb;
in {
  imports = [
    (import ./mkCaddyCfg.nix cfg)
  ];

  config = lib.mkIf cfg.enable {
    users.groups."btopweb" = {};
    users.users."btopweb" = {
      isSystemUser = true;
      group = "btopweb";
    };

    systemd.services."btopweb" = {
      description = "Host btop on a website";
      restartIfChanged = true;
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = "btopweb";
        Type = "simple";

        ExecStart = "${pkgs.gotty}/bin/gotty --reconnect --port ${toString cfg.port} ${pkgs.btop}/bin/btop";
      };
    };
  };
}
