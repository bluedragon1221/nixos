{config, ...}: {
  networking.firewall.allowedUDPPorts = [19132];
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers."Minecraft" = {
    environment = {
      EULA = "TRUE";
      EMIT_SERVER_TELEMETRY = "true";

      SERVER_NAME = "YServer";
      TZ = config.time.timeZone;
      VERSION = "1.21.131.1";
      CONTENT_LOG_FILE_ENABLED = "false";

      ALLOW_CHEATS = "false";
      DIFFICULTY = "1";
    };
    image = "itzg/minecraft-bedrock-server";
    ports = ["0.0.0.0:19132:19132/udp"];
    volumes = ["/var/lib/minecraft/:/data"];
  };
}
