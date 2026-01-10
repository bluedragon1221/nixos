{
  config,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.tsnsrv.nixosModules.default
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

  services.openssh.settings.PasswordAuthentication = lib.mkForce true;

  # services.tsnsrv = {
  #   enable = true;
  #   defaults = {
  #     authKeyPath = config.collinux.secrets."tsnsrv-authkey".path;
  #     ephemeral = true;
  #     loginServerUrl = "https://williamsfam.us.com";
  #   };

  #   services = {
  #     "adguard" = {
  #       listenAddr = ":80";
  #       toURL = "http://localhost:8001";
  #     };
  #   };
  # };

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";
}
