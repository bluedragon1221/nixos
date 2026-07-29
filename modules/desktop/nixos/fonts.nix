{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = false;
    fontconfig.enable = true;
    packages = with pkgs; [nerd-fonts.iosevka ibm-plex liberation_ttf rubik];
  };
}
