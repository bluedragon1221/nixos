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
    };

    terminal = {
      programs = {
        git = {
          enable = true;
          userName = "Collin Williams";
          userEmail = "96917990+bluedragon1221@users.noreply.github.com";
        };
        helix.enable = true;
      };
    };

    system.network = {
      networkd = {
        enable = true;
        static = {
          ip = "192.168.50.2/24";
          gateway = "192.168.50.1";
        };

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
            rootLogin = true;
          }
          {
            port = 22;
            otp = true;
          }
        ];
      };

      # navidrome = {
      #   enable = true;
      #   bind_host = "127.0.0.1";
      #   caddy.local.enable = true;
      # };

      forgejo = {
        enable = true;
        bind_host = "127.0.0.1";
        root_url = "https://forgejo.collinux";
        caddy.local.enable = true;
      };

      copyparty = {
        enable = true;
        bind_host = "127.0.0.1";

        root_url = "up.williamsfam.us.com";
        caddy.global.enable = true;

        users.collin = {
          isAdmin = true;
          passwordFile = config.collinux.secrets."collin-copyparty-password".path;
          hasPublicDir = true;
        };
      };

      ngircd.enable = true;

      caddy = {
        enable = true;
        envFile = config.collinux.secrets."caddy-env".path;
      };
    };
  };
}
