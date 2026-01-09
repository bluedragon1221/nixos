{config, ...}: let
  tailscaleIP = "100.69.180.89";
in {
  collinux = {
    user.name = "collin";

    secrets = {
      "williams-psk".file = ./williams-psk.age;
      "caddy-env".file = ./caddy-env.age;
    };

    terminal = {
      programs = {
        git = {
          enable = true;
          userName = "Collin Williams";
          userEmail = "96917990+bluedragon1221@users.noreply.github.com";
        };
      };
    };

    boot.systemd-boot.enable = true;

    services = {
      networking = {
        enable = true;
        networkd = {
          enable = true;
          ssid = "williams";
          pskFile = config.collinux.secrets."williams-psk".path;
          static = {
            ip = "192.168.50.2/24";
            gateway = "192.168.50.1";
          };
        };
        tailscale.enable = true;
        sshd = {
          enable = true;
          bind_host = tailscaleIP;
        };
      };

      selfhost = {
        adguard = {
          enable = true;
          bind_host = tailscaleIP;
        };
        forgejo = {
          enable = true;
          bind_host = tailscaleIP;
        };
        headscale = {
          enable = true;
          root_url = "https://headscale.williamsfam.us.com";
        };
        caddy = {
          enable = true;
          envFile = config.collinux.secrets."caddy-env".path;
        };
      };
    };
  };
}
