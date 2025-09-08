{pkgs, ...}: {
  packages = with pkgs; [
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
}
