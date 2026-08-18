{
  config,
  pkgs,
  lib,
  ...
}: let
  static = {
    ssid = "williams";
    pskFile = config.collinux.secrets."williams-psk".path;
    ip = "192.168.50.2/24";
    gateway = "192.168.50.1";
  };
in {
  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    networkmanager.enable = false;

    useNetworkd = true;

    firewall = {
      enable = true;
      checkReversePath = "loose";
    };

    resolvconf.enable = true;
    nameservers = ["127.0.0.1"];

    wireless = {
      enable = true;
      networks.${static.ssid}.pskRaw = "ext:psk";
      secretsFile = static.pskFile;
    };
  };
  systemd = {
    services."disable-wifi-powersave" = {
      description = "Disable wifi powersaving using iw";
      after = ["network.target"];
      serviceConfig.ExecStart = "${lib.getExe pkgs.iw} dev wlp108s0 set power_save off";
      wantedBy = ["default.target"];
    };

    network = {
      enable = true;
      wait-online = {
        enable = true;
        anyInterface = true;
      };

      networks."11-default" = {
        name = "wl*";
        networkConfig = {
          Address = static.ip;
          Gateway = static.gateway;
          DHCP = "no";
        };
      };
    };
  };

  services = {
    resolved.enable = false;

    unbound = {
      enable = true;
      settings.server = {
        interface = ["0.0.0.0"];
        port = 53;
        access-control = [
          "127.0.0.0/8 allow"
          "10.100.0.0/24 allow"
          "0.0.0.0/0 refuse"
        ];

        local-zone = [''"ganymede." redirect''];
        local-data = [''"ganymede. IN A 10.100.0.1"''];
      };
    };
  };
}
