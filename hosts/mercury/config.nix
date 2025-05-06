{
  collinux = {
    user = {
      name = "collin";
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
      terminalEmulators.foot = {
        useTmux = true;
        enable = true;
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
