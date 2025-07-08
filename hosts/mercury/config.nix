{inputs, ...}: {
  nix-furnace = {
    extraSystemModules = [
      inputs.hjem.nixosModules.default
      ./system.nix
      ./disks.nix
    ];
    extraHomeModules = [
      ./home.nix
    ];
  };

  collinux = {
    theme = "catppuccin";

    user = {
      name = "collin";
      password = "$y$j9T$08yFysn8jr9K4Wk.hYXbG0$NzY9vIbNknJViA..Jw.vF8wmQtBgEZZU.cdLQOmDvU2";
    };

    desktop = {
      sway.enable = true;
      wallpaper = ./wallpaper.jpg;
      components.fuzzel.enable = true;
      components.dunst.enable = true;

      programs = {
        firefox.enable = true;
        foot.enable = true;
      };
    };

    services = {
      audio.enable = true;
      networking = {
        enable = true;
        iwd.enable = true;
      };
      bluetooth = {
        enable = true;
        bluetuith.enable = true;
      };
    };

    terminal = {
      shells.fish.enable = true;

      programs = {
        tmux.enable = true;
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

        cmus.enable = true;
        nh.enable = true;

        helix = {
          enable = true;
          hardMode = true;
        };
      };
    };

    boot = {
      systemd-boot.enable = true;
      plymouth.enable = true;
      secureBoot.enable = true;
    };
  };
}
