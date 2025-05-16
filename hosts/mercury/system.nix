{pkgs, ...}: {
  imports = [
    ./battery.nix
    ../../system/nix.nix
  ];

  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      ibm-plex
      nerd-fonts.iosevka
    ];
  };

  system.stateVersion = "25.05";
}
