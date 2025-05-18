{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./battery.nix
    ../../system/nix.nix

    inputs.nixos-facter-modules.nixosModules.default
    {facter.reportPath = ./facter.json;}

    inputs.lanzaboote.nixosModules.default
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
