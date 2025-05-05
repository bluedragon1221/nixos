{
  collinux = {
    username = "collin";

    terminal = {
      theme = "catppuccin";

      terminalEmulators.foot = {
        useTmux = true;
        enable = true;
      };

      shells.fish.enable = true;

      programs = {
        starship = {
          enable = true;
          theme = "minimal";
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
          hardMode = true;
        };
      };
    };

    gtk.theme = "catppuccin";

    firefox = {
      theme = "catppuccin";
      profileName = "default";
    };
  };
}
