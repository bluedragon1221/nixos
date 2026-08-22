{config, ...}: {
  collinux = {
    theme = "terminal";

    secrets = {
      "williams-psk" = {
        file = ./secrets/williams-psk.age;
        owner = "wpa_supplicant";
      };

      "caddy-env".file = ./secrets/caddy-env.age;
      "caddy-root-ca-key" = {
        file = ./secrets/caddy-root-ca.key.age;
        owner = "caddy";
      };

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
        # helix.enable = true;
      };
    };

    services = {
      sshd.enable = true; # :22
      minecraft.enable = true; # :19132
      ngircd.enable = true; # :6667

      goaccess.enable = true;
      btopweb.enable = true;
      qbittorrent = {
        enable = true;
        port = 8076;
      };
      cgit.enable = true;
      filebrowser.enable = true;
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
