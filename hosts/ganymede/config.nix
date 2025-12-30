{config, ...}: {
  collinux = {
    user.name = "collin";

    secrets = {
      "williams-psk".file = ./williams-psk.age;
      "caddy-tailscale-authkey".file = ./caddy-tailscale-authkey.age;
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
        sshd.enable = true;
      };

      selfhost = {
        adguard.enable = true;
        forgejo.enable = true;
        caddy = {
          enable = true;
          envFile = config.collinux.secrets."caddy-tailscale-authkey".path;
        };
      };
    };
  };
}
