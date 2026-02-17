{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix

    ./minecraft.nix

    ./iwlwifi.nix
    ./caddy.nix
  ];

  services.tailscale.extraSetFlags = ["--advertise-exit-node"];

  # backup usb teather configuration
  systemd.network.networks."80-usb-teather" = {
    name = "enp0s20f0u2";
    networkConfig.DHCP = "yes";
  };

  systemd.services."disable-wifi-powersave" = {
    description = "Disable wifi powersaving using iw";
    after = ["network.target"];
    serviceConfig.ExecStart = "${pkgs.iw}/bin/iw dev wlp108s0 set power_save off";
    wantedBy = ["default.target"];
  };

  services.fail2ban.enable = true;

  # merge logs from subdomains
  services.caddy.virtualHosts."up.williamsfam.us.com".logFormat = lib.mkForce ''
    output file /var/log/caddy/access-williamsfam.us.com.log
  '';

  # i broke something and this fixes it
  environment.etc."systemd/resolved.conf.d/10-dns.conf".text = config.environment.etc."systemd/resolved.conf".text;
}
