{
  networking.firewall.allowedUDPPorts = [19132];
  virtualisation.oci-containers.containers = {
    "Minecraft" = {
      environment = {
        EULA = "TRUE";
        SERVER_NAME = "YServer";
        TZ = "America/Chicago";
        VERSION = "LATEST";
        ALLOW_CHEATS = "false";
        DIFFICULTY = "1";
      };
      image = "itzg/minecraft-bedrock-server";
      ports = ["0.0.0.0:19132:19132/udp"];
      volumes = ["/srv/minecraft/:/data"];
    };
  };
}
