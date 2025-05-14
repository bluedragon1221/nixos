{pkgs, ...}: {
  home.preferXdgDirectories = true;
  home.packages = with pkgs; [
    # GUI apps
    musescore
    tor-browser # don't ask
    obsidian
    kdePackages.kleopatra
    mpv
  ];

  programs.nh.enable = true;

  home.stateVersion = "25.05";
}
