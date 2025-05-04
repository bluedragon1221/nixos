{
  collinux = {
    username = "collin";

    terminal = {
      theme = "adwaita";

      terminalEmulators.blackbox.enable = true;

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

    gtk.theme = "adwaita";

    firefox = {
      theme = "adwaita";
      profileName = "default";
    };
  };
}
