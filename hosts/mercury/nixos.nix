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
      LocalForward 8010 127.0.0.1:8010

    Match host ganymede !exec "nc -z -w1 192.168.50.2 2222"
      HostName williamsfam.us.com
      Port 22
      DynamicForward 9090

    Match host ganymede exec "nc -z -w1 192.168.50.2 2222"
      HostName 192.168.50.2
      Port 2222

    Host io
      Hostname 192.168.50.3

    Match host io !exec "nc -z -w1 192.168.50.3 22"
      ProxyJump ganymede
  '';
}
