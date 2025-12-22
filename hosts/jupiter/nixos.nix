{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./disks.nix
    inputs.nixos-facter-modules.nixosModules.facter
  ];

  systemd.network.wait-online.enable = false; # fix for weird wifi issue

  fonts.packages = [pkgs.nerd-fonts.iosevka];

  facter.reportPath = ./facter.json;
  time.timeZone = "America/Chicago";
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";
}
