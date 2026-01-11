{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = false;
    fontconfig.enable = true;
    packages = [pkgs.nerd-fonts.iosevka pkgs.ibm-plex]; # for terminal (blackbox or foot or ghostty)
  };
}
