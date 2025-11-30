{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix

    ./minecraft.nix
    ./samba.nix

    inputs.nixos-facter-modules.nixosModules.facter
    {facter.reportPath = ./facter.json;}
  ];

  time.timeZone = "America/Chicago";

  services.pipewire.jack.enable = true;
  environment.systemPackages = with pkgs; [vital helvum];

  system.stateVersion = "25.05";
}
