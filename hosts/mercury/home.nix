{pkgs, ...}: {
  home.packages = with pkgs; [
    # GUI apps
    tor-browser # don't ask
    obsidian
    kdePackages.kleopatra
    mpv
  ];

  home.stateVersion = "25.05";
}
