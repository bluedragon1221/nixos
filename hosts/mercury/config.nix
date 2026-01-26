{
  collinux = {
    theme = "catppuccin";

    user = {
      name = "collin";
      useRun0 = true;
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
        networkd = {
          enable = true;
        };
      };
      bluetooth.enable = true;
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
        # nh.enable = true;
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
