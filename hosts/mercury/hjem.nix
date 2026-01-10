{pkgs, ...}: {
  packages = with pkgs; [
    # GUI apps
    tor-browser # don't ask
    obsidian
    kdePackages.kleopatra
    mpv
    musescore
    zed-editor # experimenting

    kew # music player
    prismlauncher

    vital
  ];
}
