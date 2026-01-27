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

  programs.ssh.extraConfig = ''
    Host ganymede
      HostName 192.168.50.2
      Port 2222
  '';

  programs.firefox.policies.ExtensionSettings = {
    "foxyproxy@eric.h.jung" = {
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/latest.xpi";
    };
  };
}
