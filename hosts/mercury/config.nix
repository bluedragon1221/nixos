{pkgs, ...}: {
  collinux = {
    theme = "catppuccin";
    user.name = "collin";

    desktop = {
      wallpaper = ./wallpaper.jpg;

      # gtk.enable = true;

      greetd.enable = true;

      wm = {
        # sway.enable = true;
        niri.enable = true;
        components.fuzzel.enable = true;
        components.dunst.enable = true;
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
        lazygit.enable = true;
        starship.enable = true;

        fzf.enable = true;
        bat.enable = true;
        eza.enable = true;

        git = {
          enable = true;
          userName = "Collin Williams";
          userEmail = "96917990+bluedragon1221@users.noreply.github.com";
        };

        nh.enable = true;

        helix = {
          enable = true;
          hardMode = true;
        };
      };
    };

    boot = {
      systemd-boot.enable = true;
      secureBoot.enable = true;
    };
  };
}
