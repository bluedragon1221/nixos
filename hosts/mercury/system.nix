{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./battery.nix
    ./ai.nix

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

  networking.firewall.allowedUDPPorts = [445];
  networking.firewall.allowedTCPPorts = [8000];
  users.users.collin.packages = [pkgs.cifs-utils];
  fonts.fontDir.enable = true;

  system.stateVersion = "25.05";
}
