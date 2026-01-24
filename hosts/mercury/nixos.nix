{
  lib,
  inputs,
  ...
}: {
  imports = [
    ./disks.nix
    ./battery.nix
    ./ai.nix

    inputs.nixos-facter-modules.nixosModules.facter
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  facter.reportPath = ./facter.json;

  services.syncthing = {
    enable = true;
    user = "collin";
    dataDir = "/home/collin/.local/syncthing";
  };

  services.printing.enable = true;

  environment.defaultPackages = lib.mkForce []; # im not a noob

  # programs.firefox.policies.Preferences.ExtensionSettings = {

  # };

  programs.ssh.extraConfig = ''
    Host ganymede
      HostName 70.130.121.193
      User collin
      IdentityFile /home/collin/.ssh/id_ed25519
      LocalForward 8015 127.0.0.1:8015
  '';
}
