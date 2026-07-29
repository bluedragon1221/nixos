{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-facter-modules.nixosModules.facter
    ./disks.nix
    ./caddy.nix
    ./wireguard.nix
  ];

  facter.reportPath = ./facter.json;

  systemd.services."disable-wifi-powersave" = {
    description = "Disable wifi powersaving using iw";
    after = ["network.target"];
    serviceConfig.ExecStart = "${pkgs.iw}/bin/iw dev wlp108s0 set power_save off";
    wantedBy = ["default.target"];
  };

  services.fail2ban.enable = true;

  # merge logs from subdomains
  services.caddy.virtualHosts."jta.williamsfam.us.com".logFormat = lib.mkForce ''
    output file /var/log/caddy/access-williamsfam.us.com.log
  '';
}
