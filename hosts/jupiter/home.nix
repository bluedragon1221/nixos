{pkgs, ...}: {
  # imports = [

  #   ../../home/helix.nix
  # ];

  home.preferXdgDirectories = true;
  # home.packages = with pkgs; [
  #   bambu-studio
  #   bottles
  #   musescore
  #   obsidian
  #   nicotine-plus
  #   freecad-wayland
  # ];

  collinux = {
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

  home.stateVersion = "25.05";
}
