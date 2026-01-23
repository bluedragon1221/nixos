{config, ...}: {
  collinux = {
    user.name = "collin";

    secrets = {
      "williams-psk" = {
        file = ./williams-psk.age;
        owner = "wpa_supplicant";
      };

      "caddy-env".file = ./caddy-env.age;

      "wg-key" = {
        file = ./ganymede-wg-key.age;
        owner = "systemd-network";
      };
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
        # tailscale = {
        #   enable = true;
        #   tailnet = "collinux.tailnet";
        # };
        sshd = {
          enable = true;
          bind_host = "0.0.0.0";
        };
      };

      selfhost = {
        caddy = {
          enable = true;
          envFile = config.collinux.secrets."caddy-env".path;
        };

        forgejo = {
          enable = true;
          bind_host = "127.0.0.1";
          root_url = "ganymede.collinux.tailnet:8010";
        };

        # headscale = {
        #   enable = true;
        #   root_url = "headscale.williamsfam.us.com";
        #   caddy.enable = true;
        # };
      };
    };
  };
}
