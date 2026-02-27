{config, ...}: {
  collinux = {
    theme = "terminal";

    secrets = {
      "williams-psk" = {
        file = ./williams-psk.age;
        owner = "wpa_supplicant";
      };

      "caddy-env".file = ./caddy-env.age;

      "collin-copyparty-password" = {
        file = ./collin-copyparty-password.age;
        owner = "copyparty";
      };
      "collin-forgejo-password" = {
        file = ./collin-forgejo-password.age;
        owner = "forgejo";
      };
      "wireguard-pk" = {
        file = ./wireguard-pk.age;
        owner = "systemd-network";
      };
    };

    terminal = {
      programs = {
        git = {
          enable = true;
          userName = "Collin Williams";
          userEmail = "96917990+bluedragon1221@users.noreply.github.com";
          installKey = true;
        };
        helix.enable = true;
      };
    };

    system.network = {
      static = {
        ip = "192.168.50.2/24";
        gateway = "192.168.50.1";
      };
      wireless.static = {
        ssid = "williams";
        pskFile = config.collinux.secrets."williams-psk".path;
      };
    };

    services = {
      sshd = {
        enable = true;
        portConfig = [
          {
            port = 2222;
            listenAddr = "0.0.0.0";
            rootLogin = true;
          }
          {
            port = 22;
            listenAddr = "0.0.0.0";
          }
        ];
      };

      goaccess = {
        enable = true;
        privateUrl = "stats.ganymede";
      };
      btopweb = {
        enable = true;
        privateUrl = "btop.ganymede";
      };

      cgit = {
        enable = true;
        privateUrl = "git.ganymede";
      };

      polaris = {
        enable = true;
        privateUrl = "music.ganymede";
      };

      qbittorrent = {
        enable = true;
        privateUrl = "bittorrent.ganymede";
      };
      copyparty = {
        enable = true;
        publicUrl = "up.williamsfam.us.com";
        privateUrl = "files.ganymede";

        users.collin = {
          isAdmin = true;
          passwordFile = config.collinux.secrets."collin-copyparty-password".path;
          hasPublicDir = true;
        };
      };

      caddy = {
        enable = true;
        envFile = config.collinux.secrets."caddy-env".path;
      };
    };
  };
}
