{config, ...}: let
  tailscaleIP = "100.100.218.182";
in {
  collinux = {
    user.name = "collin";

    secrets = {
      "williams-psk" = {
        file = ./williams-psk.age;
        owner = "wpa_supplicant";
      };

      "caddy-env".file = ./caddy-env.age;
      "tsnsrv-authkey".file = ./tsnsrv-authkey.age;

      "wg-key".file = ./ganymede-wg-key.age;
    };

    wireguard = {
      enable = true;
      ip = "100.100.0.1";
      gateway = "100.100.0.1";
      privateKeyFile = config.collinux.secrets."wg-key".path;
      peers = [
        {
          # mercury
          publicKey = "EDDppGqbLfEwEcHLP3J+bxKVGW16fAcU83K/ZKR2h3A=";
          ip = "100.100.0.5/32";
        }
        {
          # jupiter
          publicKey = "Pi1PydaaEz9IcAZ+elH5HkzEa2D35P/tUy+9KKH6PHI=";
          ip = "100.100.0.10/32";
        }
      ];
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
        tailscale = {
          enable = true;
          tailnet = "collinux.tailnet";
        };
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
          bind_host = tailscaleIP;
          root_url = "ganymede.collinux.tailnet:8010";
        };

        headscale = {
          enable = true;
          root_url = "headscale.williamsfam.us.com";
          caddy.enable = true;
        };
      };
    };
  };
}
