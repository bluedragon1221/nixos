{config, ...}: {
  collinux = {
    theme = "catppuccin";

    secrets = {};

    user.useRun0 = true;

    desktop = {
      wallpaper =
        if (config.collinux.theme == "catppuccin")
        then ./wallpapers/astronaut.jpg
        else ./wallpapers/hintergrund2.png;
      gtk.enable = true;
      qt.enable = true;

      greetd = {
        enable = true;
        autologin.enable = true;
      };

      wm = {
        niri.enable = true;
        # sway.enable = true;
        kdeDesktopPortal.enable = true;

        components = {
          fuzzel.enable = true;
        };
      };

      programs = {
        firefox = {
          enable = true;
          extensions.foxyproxy.enable = true;
        };
        foot.enable = true;

        research.enable = true;
      };
    };

    system = {
      boot = {
        systemd-boot.enable = true;
        secureBoot.enable = true;
      };

      network.wireless.dynamic = true;

      audio.enable = true;
      bluetooth.enable = true;
      printing.enable = true;
    };

    terminal = {
      shells = {
        fish.enable = true;
        bash.enable = true; # for nix-shells
      };

      programs = {
        starship.enable = true;
        fzf.enable = true;
        bat.enable = true;
        eza.enable = true;
        broot.enable = true;
        tmux.enable = true;
        helix = {
          enable = true;
          hardMode = true;
        };

        lazygit.enable = true;
        git = {
          enable = true;
          userName = "Collin Williams";
          userEmail = "96917990+bluedragon1221@users.noreply.github.com";
          installKey = true;
        };
      };
    };
  };
}
