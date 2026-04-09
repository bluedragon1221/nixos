{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.jta;

  package = pkgs.callPackage ./pkg.nix {};
in {
  imports = [
    (import ../mkCaddyCfg.nix cfg)
  ];

  config = lib.mkIf cfg.enable {
    users.groups."jta" = {};
    users.users."jta" = {
      isSystemUser = true;
      group = "jta";
      extraGroups = ["fileserver"];

      home = "/var/lib/jta";
      createHome = true;
      homeMode = "755";
    };

    systemd.services."jta" = {
      description = "Juksere trives aldri, kids";
      restartIfChanged = true;
      wants = ["network-online.target" "caddy.service"];
      after = ["network-online.target" "caddy.service"];

      environment = {
        PORT = toString cfg.port;
        ROOT_DIR = "/media/jta";
        AUTH_PASSWORD_HASH = "550b6785c4bce2ab41a5e2eaa1eb43172d5abbd58237f1c78cd32cb190edc2c5"; # alfreddabuttlerwithtwots
      };

      serviceConfig = {
        User = "jta";
        Type = "simple";

        WorkingDirectory = "/var/lib/jta";
        ExecStart = "${package}/bin/jta";
      };

      wantedBy = ["multi-user.target"];
    };
  };
}
