{config, ...}: {
  collinux = {
    theme = "catppuccin";
    user.name = "collin";

    secrets = {
      "wg-key".file = ./mercury-wg-key.age;
    };

    wireguard = {
      enable = true;
      ip = "100.100.0.5";
      gateway = "100.100.0.1";
      privateKeyFile = config.collinux.secrets."wg-key".path;
      peers = [
        {
          # ganymede
          publicKey = "WNLf8M6JGSHeRVvbAF6E/6oxAHeNxv6bXqqlmwMdvlk=";
          ip = "100.100.0.0/24";
          endpoint = "williamsfam.us.com:51820";
        }
      ];
    };

    desktop = {
      wallpaper = ./wallpapers/abstract-swirls.jpg;
      gtk.enable = true;
      greetd = {
        enable = true;
        autologin.enable = true;
      };

      wm = {
        sway.enable = true;

        components = {
          fuzzel.enable = true;
          dunst.enable = true;
        };
      };

      programs = {
        firefox.enable = true;
        foot.enable = true;

        research.enable = true;
      };
    };

    services = {
      audio.enable = true;
      networking = {
        enable = true;
        iwd.enable = true;
        tailscale.enable = true;
      };
      bluetooth = {
        enable = true;
        bluetuith.enable = true;
      };
    };

    terminal = {
      shells.fish.enable = true;
      shells.bash.enable = true; # for nix-shells

      programs = {
        starship.enable = true;
        fzf.enable = true;
        bat.enable = true;
        eza.enable = true;
        helix = {
          enable = true;
          hardMode = true;
        };

        tmux.enable = true;

        lazygit.enable = true;
        nh.enable = true;
        git = {
          enable = true;
          userName = "Collin Williams";
          userEmail = "96917990+bluedragon1221@users.noreply.github.com";
          installKey = true;
        };
      };
    };

    boot = {
      systemd-boot.enable = true;
      secureBoot.enable = true;
    };
  };
}
