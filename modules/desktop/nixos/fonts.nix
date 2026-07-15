{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = false;
    fontconfig.enable = true;
    packages = [pkgs.nerd-fonts.iosevka pkgs.ibm-plex pkgs.liberation_ttf pkgs.rubik]; # for terminal (blackbox or foot or ghostty)
  };
}
