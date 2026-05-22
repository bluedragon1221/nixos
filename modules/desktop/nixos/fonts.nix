{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = false;
    fontconfig.enable = true;
    packages = [pkgs.nerd-fonts.iosevka pkgs.ibm-plex pkgs.liberation_ttf]; # for terminal (blackbox or foot or ghostty)
  };
}
