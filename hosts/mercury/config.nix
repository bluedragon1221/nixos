{...} @ args: {
  collinux = {
    user = {
      fullName = "Collin Williams";
      name = args.username;
      email = "96917990+bluedragon1221@users.noreply.github.com";
      password = "$y$j9T$08yFysn8jr9K4Wk.hYXbG0$NzY9vIbNknJViA..Jw.vF8wmQtBgEZZU.cdLQOmDvU2";
    };

    theme = "catppuccin";

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
    };

    terminal = {
      terminalEmulators = {
        useTmux = true;
        foot.enable = true;
      };

      shells.fish.enable = true;

      programs = {
        starship.enable = true;
        bat.enable = true;
        eza.enable = true;
        fzf.enable = true;

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
    };

    networking = {
      enable = true;
      wifiDaemon = "iwd";
    };

    firefox.enable = true;
  };
}
