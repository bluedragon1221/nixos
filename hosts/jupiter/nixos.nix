{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix

    ./samba.nix

    inputs.nixos-facter-modules.nixosModules.facter
    {facter.reportPath = ./facter.json;}
  ];

  time.timeZone = "America/Chicago";

  systemd.network.wait-online.enable = false; # fix for weird wifi issue

  # music stuff
  environment.systemPackages = with pkgs; [vital helvum bambu-studio];

  fonts.packages = [pkgs.nerd-fonts.iosevka];

  system.stateVersion = "25.05";

  nixpkgs.hostPlatform = "x86_64-linux";
}
