{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = false;
    # fontDir.enable = true;
    fontconfig.enable = true;
    packages = [pkgs.nerd-fonts.iosevka pkgs.ibm-plex]; # for terminal (blackbox or foot)
  };
}
