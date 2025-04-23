{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      ibm-plex
      nerd-fonts.iosevka
    ];
  };
}
