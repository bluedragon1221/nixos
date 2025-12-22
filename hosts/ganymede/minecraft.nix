{config, ...}: {
  networking.firewall.allowedUDPPorts = [19132];

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    "Minecraft" = {
      environment = {
        EULA = "TRUE";
        EMIT_SERVER_TELEMETRY = "true";

        SERVER_NAME = "YServer";
        TZ = config.time.timeZone;
        VERSION = "1.21.81.2";
        CONTENT_LOG_FILE_ENABLED = "true";

        ALLOW_CHEATS = "false";
        DIFFICULTY = "1";
      };
      image = "itzg/minecraft-bedrock-server";
      ports = ["0.0.0.0:19132:19132/udp"];
      volumes = ["/srv/minecraft/:/data"];

      podman.sdnotify = "conmon"; # avoid nasty errors about healthcheck (idk, the service runs fine)
    };
  };
}
