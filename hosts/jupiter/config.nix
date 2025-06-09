{inputs, ...}: {
  nix-furnace = {
    extraHomeModules = [
      ./home.nix
    ];

    extraSystemModules = [
      ./system.nix
    ];
  };

  collinux = {
    theme = "adwaita";

    user = {
      name = "collin";
      email = "96917990+bluedragon1221@users.noreply.github.com";
      password = "$y$j9T$08yFysn8jr9K4Wk.hYXbG0$NzY9vIbNknJViA..Jw.vF8wmQtBgEZZU.cdLQOmDvU2";
    };

    desktop = {
      gnome.enable = true;

      programs = {
        firefox.enable = true;
      };
    };

    terminal = {
      theme = "adwaita";

      terminalEmulators.blackbox.enable = true;

      shells.fish.enable = true;

      programs = {
        bat.enable = true;
        eza.enable = true;
        fzf.enable = true;

        nh.enable = true;
        lazygit.enable = true;

        starship = {
          enable = true;
          theme = "default";
        };

        helix = {
          enable = true;
          hardMode = false;
        };
      };
    };

    boot = {
      theme = "default";
      bootloader = "systemd-boot";
      plymouth.enable = true;
    };

    networking = {
      enable = true;
      wifiDaemon = "networkmanager"; # apparently gnome doesn't support iwd
    };
  };
}
