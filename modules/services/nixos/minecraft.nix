{
  lib,
  config,
  ...
}: let
  cfg = config.collinux.services.minecraft;
in
  lib.mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [cfg.port];

    virtualisation.oci-containers.containers."Minecraft" = {
      environment = {
        EULA = "TRUE";
        EMIT_SERVER_TELEMETRY = "true";

        SERVER_NAME = "YServer";
        TZ = config.time.timeZone;
        VERSION = "1.26.31.1";
        CONTENT_LOG_FILE_ENABLED = "false";

        ALLOW_CHEATS = "false";
        DIFFICULTY = "1";
      };
      image = "itzg/minecraft-bedrock-server";
      ports = [
        "0.0.0.0:${toString cfg.port}:19132/udp"
      ];
      volumes = ["/var/lib/minecraft/:/data"];

      extraOptions = ["--no-healthcheck"];
    };
  }
