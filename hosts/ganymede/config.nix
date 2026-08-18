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

    services = {
      sshd.enable = true; # :22
      minecraft.enable = true; # :19132
      ngircd.enable = true; # :6667

      jta = {
        enable = true;
        port = 8072;
      };
      goaccess = {
        enable = true;
        port = 7890;
      };
      btopweb = {
        enable = true;
        port = 8017;
      };
      qbittorrent = {
        enable = true;
        port = 8076;
      };
      cgit.enable = true;
      glance = {
        enable = true;
        port = 8081;
      };
      filebrowser = {
        enable = true;
        port = 8082;
      };

      caddy = {
        enable = true;
        envFile = config.collinux.secrets."caddy-env".path;
      };
    };
  };
}
