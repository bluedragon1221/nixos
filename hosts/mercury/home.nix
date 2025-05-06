{pkgs, ...}: {
  imports = [
    ../../home/nh.nix
    ../../home/cmus

    ../../home/git.nix
  ];

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
