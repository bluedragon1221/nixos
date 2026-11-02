{
  config,
  pkgs,
  lib,
  ...
}: let
  static = {
    ssid = "williams";
    pskFile = config.collinux.secrets."williams-psk".path; # file should look like "psk=<PSK>"
    ip = "192.168.50.2/24";
    gateway = "192.168.50.1";
  };
in {
  networking = {
    nftables.enable = true;
    dhcpcd.enable = false;
    useDHCP = false;
    networkmanager.enable = false;
    useNetworkd = true;

    nameservers = ["127.0.0.1"];
    resolvconf.enable = true;

    firewall = {
      enable = true;
      checkReversePath = "loose";
    };

    wireless = {
      enable = true;
      secretsFile = static.pskFile;
      networks.${static.ssid}.pskRaw = "ext:psk";
    };
  };
  systemd = {
    services."disable-wifi-powersave" = let
      interface = "wlp108s0";
      dev = "sys-subsystem-net-devices-${interface}.device";
    in {
      bindsTo = [dev];
      after = [dev];
      wantedBy = [dev];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${lib.getExe pkgs.iw} dev ${interface} set power_save off";
      };
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
          IPv6AcceptRA = "yes";
        };
        ipv6AcceptRAConfig = {
          Token = "prefixstable";
          UseDNS = false;
        };
      };

      # for next time I break networking...
      networks."20-tether" = {
        name = "enp*";
        networkConfig.DHCP = "yes";
      };
    };
  };

  services = {
    resolved.enable = false;

    unbound = {
      enable = true;
      settings.server = {
        interface = ["0.0.0.0" "::1"];
        port = 53;
        access-control = [
          "127.0.0.0/8 allow"
          "10.100.0.0/24 allow"
          "0.0.0.0/0 refuse"
        ];

        val-permissive-mode = "yes";

        local-zone = [''"ganymede." redirect''];
        local-data = [''"ganymede. IN A 10.100.0.1"''];
      };
    };
  };
}
