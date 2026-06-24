{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.ganyupload;
  package = pkgs.callPackage ./pkg.nix {};
in {
  config = lib.mkIf cfg.enable {
    users.groups."ganyupload" = {};
    users.users."ganyupload" = {
      isSystemUser = true;
      group = "ganyupload";
      home = "/var/lib/ganyupload";
      createHome = true;
      homeMode = "755";
    };

    systemd.services."ganyupload" = {
      description = "Ganymede File Upload Service";
      restartIfChanged = true;
      wants = ["network-online.target" "caddy.service"];
      after = ["network-online.target" "caddy.service"];

      environment = {
        PORT = toString cfg.port;
        UPLOAD_DIR = "/media/ganyupload";
      };

      serviceConfig = {
        User = "ganyupload";
        Type = "simple";

        WorkingDirectory = "/var/lib/ganyupload";
        ExecStart = "${package}/bin/ganyupload";
      };

      wantedBy = ["multi-user.target"];
    };

    services.caddy.virtualHosts."upld.williamsfam.us.com".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString cfg.port}
    '';
  };
}
