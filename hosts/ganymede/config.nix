{config, ...}: {
  collinux = {
    theme = "terminal";

    secrets = {
      "williams-psk" = {
        file = ./secrets/williams-psk.age;
        owner = "wpa_supplicant";
      };

      "caddy-env".file = ./secrets/caddy-env.age;
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
        public = true;

        conf.rootLogin = true;
      };

      minecraft = {
        enable = true;
        public = true;
      };

      ngircd = {
        enable = true;
        public = true;
      };

      jta = {
        enable = true;
        publicUrl = "jta.williamsfam.us.com";
      };
      ganyupload = {
        enable = true;
        publicUrl = "upld.williamsfam.us.com";
      };
      goaccess = {
        enable = true;
        privateUrl = "stats.ganymede";
      };
      btopweb = {
        enable = true;
        privateUrl = "btop.ganymede";
      };
      qbittorrent = {
        enable = true;
        privateUrl = "bittorrent.ganymede";
      };
      cgit = {
        enable = true;
        privateUrl = "git.ganymede";
      };

      caddy = {
        enable = true;
        envFile = config.collinux.secrets."caddy-env".path;
      };
    };
  };
}
