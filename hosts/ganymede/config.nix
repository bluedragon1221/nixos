{config, ...}: {
  collinux = {
    theme = "terminal";

    secrets = {
      "williams-psk" = {
        file = ./secrets/williams-psk.age;
        owner = "wpa_supplicant";
      };

      "caddy-env".file = ./secrets/caddy-env.age;

      "wireguard-privkey" = {
        file = ./secrets/wg-privkey.age;
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
        public = true;

        conf.rootLogin = true;
      };

      minecraft = {
        enable = true;
        port = 19132; # standard
        public = true;
      };

      ngircd = {
        enable = true;
        port = 6667; # standard
        public = true;
      };

      jta = {
        enable = true;
        port = 8072;
        publicUrl = "jta.williamsfam.us.com";
      };
      ganyupload = {
        enable = true;
        port = 8073;
        publicUrl = "upld.williamsfam.us.com";
      };
      goaccess = {
        enable = true;
        port = 7890;
        privateUrl = "stats.ganymede";
      };
      btopweb = {
        enable = true;
        port = 8017;
        privateUrl = "btop.ganymede";
      };
      qbittorrent = {
        enable = true;
        port = 8076;
        privateUrl = "bittorrent.ganymede";
      };
      cgit = {
        enable = true;
        privateUrl = "git.ganymede";
      };
      glance = {
        enable = true;
        port = 8081;
      };

      caddy = {
        enable = true;
        envFile = config.collinux.secrets."caddy-env".path;
      };
    };
  };
}
