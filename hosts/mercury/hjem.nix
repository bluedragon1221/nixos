{pkgs, ...}: {
  packages = with pkgs; [
    # GUI apps
    tor-browser # don't ask
    obsidian
    kdePackages.kleopatra
    mpv
    musescore

    kew # music player
    prismlauncher

    vital
  ];
}
