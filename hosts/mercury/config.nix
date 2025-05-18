{inputs, ...}: {
  nix-furnace = {
    extraSystemModules = [
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
      fullName = "Collin Williams";
      email = "96917990+bluedragon1221@users.noreply.github.com";
      password = "$y$j9T$08yFysn8jr9K4Wk.hYXbG0$NzY9vIbNknJViA..Jw.vF8wmQtBgEZZU.cdLQOmDvU2";
    };

    desktop = {
      hyprland = {
        enable = true;
        useUwsm = true;
        components = {
          waybar.enable = true;
          dunst.enable = true;
          fuzzel.enable = true;
        };
      };

      programs = {
        firefox.enable = true;
        musescore.enable = true;
      };
    };

    services = {
      audio.enable = true;
      networking = {
        enable = true;
        wifiDaemon = "iwd";
      };
      bluetooth.enable = true;
    };

    terminal = {
      terminalEmulators = {
        useTmux = true;
        foot.enable = true;
      };

      shells.fish.enable = true;

      programs = {
        starship = {
          enable = true;
          style = "minimal";
        };
        bat.enable = true;
        eza.enable = true;
        fzf.enable = true;

        nh.enable = true;
        cmus.enable = true;

        helix = {
          enable = true;
          hardMode = true;
        };
      };
    };

    boot = {
      bootloader = "systemd-boot";
      plymouth.enable = true;
      secureBoot.enable = true;
    };
  };
}
