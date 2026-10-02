{
  inputs,
  hosts,
  lib,
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

  programs.ssh.extraConfig =
    hosts
    |> (lib.mapAttrsToList (hostname: hostAttrs:
      if hostAttrs ? ip
      then
        ''
          Host ${hostname}
            HostName ${hostAttrs.ip}
        ''
        + (
          if hostAttrs ? jump
          then "  ProxyJump ${hostAttrs.jump}"
          else ""
        )
      else ""))
    |> (builtins.filter (s: s != ""))
    |> (lib.concatStringsSep "\n");

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
