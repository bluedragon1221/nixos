{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./battery.nix

    inputs.nixos-facter-modules.nixosModules.facter
    {facter.reportPath = ./facter.json;}

    inputs.lanzaboote.nixosModules.lanzaboote
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
