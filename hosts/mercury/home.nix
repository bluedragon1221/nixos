{pkgs, ...}: {
  home.preferXdgDirectories = true;
  home.packages = with pkgs; [
    # GUI apps
    tor-browser # don't ask
    obsidian
    kdePackages.kleopatra
    mpv
    musescore
    qutebrowser

    zotero
    zathura
  ];

  home.stateVersion = "25.05";
}
