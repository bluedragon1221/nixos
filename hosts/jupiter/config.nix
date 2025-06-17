{inputs, ...}: {
  nix-furnace = {
    extraHomeModules = [
      ./home.nix
    ];

    extraSystemModules = [
      ./system.nix
      inputs.hjem.nixosModules.default
    ];
  };

  collinux = {
    theme = "adwaita";

    user = {
      name = "collin";
      password = "$y$j9T$08yFysn8jr9K4Wk.hYXbG0$NzY9vIbNknJViA..Jw.vF8wmQtBgEZZU.cdLQOmDvU2";
    };

    desktop = {
      gnome.enable = true;

      programs = {
        firefox.enable = true;
        blackbox.enable = true;
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

        git = {
          enable = true;
          userName = "Collin Williams";
          userEmail = "96917990+bluedragon1221@users.noreply.github.com";
        };
      };
    };

    boot = {
      bootloader = "systemd-boot";
      plymouth.enable = true;
    };

    services = {
      networking = {
        enable = true;
        wifiDaemon = "networkmanager"; # apparently gnome doesn't support iwd
      };

      audio = {
        enable = true;
        pulse.enable = true;
      };

      bluetooth.enable = true;
    };
  };
}
