{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../modules/home/terminal

    # Desktop
    ../../home/hyprland.nix
    ../../home/waybar
    ../../home/dunst.nix
    ../../home/gtk.nix

    # GUI
    ../../home/fuzzel.nix
    ../../home/foot.nix

    # Term
    ../../home/git.nix
    ../../home/nh.nix
    ../../home/cmus
  ];

  collinux = {
    terminal = {
      theme = "catppuccin";

      terminalEmulators.foot = {
        enable = true;
        useTmux = true;
      };

      shells = {
        fish.enable = true;
      };

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
    firefox = {
      theme = "catppuccin";
      profileName = "default";
    };
  };

  home.preferXdgDirectories = true;
  home.packages = with pkgs; [
    # GUI apps
    musescore
    obsidian
    kdePackages.kleopatra
    mpv
  ];

  home.stateVersion = "25.05";
}
