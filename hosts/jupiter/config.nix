{
  collinux = {
    username = "collin";

    terminal = {
      theme = "adwaita";

      terminalEmulators = {
        useTmux = true;
        blackbox.enable = true;
      };

      shells.fish.enable = true;

      programs = {
        starship = {
          enable = true;
          theme = "default";
        };

        bat = {
          enable = true;
          alias = true;
        };

        eza = {
          enable = true;
          alias = true;
        };

        fzf.enable = true;

        helix = {
          enable = true;
          hardMode = false;
        };
      };
    };

    bootloader = {
      theme = "default";
      bootloader = "systemd-boot";
      plymouth.enable = true;
    };

    gtk.theme = "adwaita";

    networking = {
      enable = true;
      wifiDaemon = "networkmanager"; # apparently gnome doesn't support iwd
    };

    firefox = {
      enable = true;
      theme = "adwaita";
      profileName = "default";
    };
  };
}
