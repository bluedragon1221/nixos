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

  programs.firefox.policies.ExtensionSettings = {
    "foxyproxy@eric.h.jung" = {
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/latest.xpi";
    };
  };

  programs.ssh.extraConfig = ''
    Host ganymede
      HostName williamsfam.us.com
      User collin
      IdentityFile /home/collin/.ssh/id_ed25519
      LocalForward 8010 127.0.0.1:8010
      DynamicForward 9090

    Host ganymede-deploy
      HostName 192.168.0.2
      User root
      IdentityFile /home/collin/.ssh/id_ed25519

    Host io
      Hostname 192.168.50.3
      User admin
      IdentityFile /home/collin/.ssh/id_ed25519
      ProxyJump ganymede
  '';
}
