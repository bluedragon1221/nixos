{
  collinux = {
    theme = "adwaita";

    user.name = "collin";

    desktop = {
      gnome.enable = true;
      gdm.enable = true;
      gtk.enable = true;

      programs = {
        firefox.enable = true;
        ghostty.enable = true;
      };
    };

    terminal = {
      shells.fish.enable = true;

      programs = {
        lazygit.enable = true;

        starship = {
          enable = true;
          theme = "default";
        };

        helix = {
          enable = true;
          hardMode = false;
        };

        tmux.enable = true;
        broot.enable = true;

        git = {
          enable = true;
          userName = "Collin Williams";
          userEmail = "96917990+bluedragon1221@users.noreply.github.com";
          installKey = true;
        };
      };
    };

    boot = {
      timeout = 5;
      systemd-boot.enable = true;
      plymouth.enable = true;
    };

    services = {
      networking = {
        enable = true;
        networkmanager.enable = true;
        tailscale.enable = true;
        sshd.enable = true;
      };

      audio.enable = true;

      bluetooth.enable = true;
    };
  };
}
