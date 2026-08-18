{
  config,
  pkgs,
  ...
}: {
  collinux = {
    theme = "catppuccin";

    secrets = {
      "wireguard-privkey" = {
        file = ./secrets/wg-privkey.age;
        owner = "systemd-network";
      };
    };

    user.useRun0 = true;

    desktop = {
      wallpaper = "${pkgs.gnome-backgrounds}/share/backgrounds/gnome/blobs-d.svg";

      gtk.enable = true;
      qt.enable = true;

      greetd = {
        enable = true;
        autologin.enable = true;
      };

      wm = {
        niri.enable = true;
        kdeDesktopPortal.enable = true;
        components.fuzzel.enable = true; # noctalia launcher SUCKS
      };

      programs = {
        firefox.enable = true;
        research.enable = true;
        foot.enable = true;
      };
    };

    system = {
      boot = {
        systemd-boot.enable = true;
        plymouth.enable = true;
        secureBoot.enable = true;
      };

      # network.wireless.dynamic = true;

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
