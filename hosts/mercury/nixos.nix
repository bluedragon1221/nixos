{
  inputs,
  hosts,
  ...
}: {
  imports = [
    ./disks.nix
    ./battery.nix

    ./wireguard.nix
    ./networking.nix

    inputs.nixos-facter-modules.nixosModules.facter
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  facter.reportPath = ./facter.json;

  services.upower.enable = true;

  programs.ssh.extraConfig = ''
    Host ganymede
      HostName 10.100.0.1
      Port 22
  '';

  programs.kdeconnect.enable = true;

  security.pki.certificates = [
    hosts.ganymede.caddy-root-ca
  ];

  # get perl out of my closure
  system = {
    etc.overlay.enable = true;
    nixos-init.enable = true;
  };

  # required for vm testing
  virtualisation.vmVariant.virtualisation.diskSize = 8192;
}
