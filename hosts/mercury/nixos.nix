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

  security.soteria.enable = true;

  services.printing.enable = true;

  environment.defaultPackages = lib.mkForce []; # im not a noob

  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIBozCCAUmgAwIBAgIQbfaguvgtbo/JBep9INWMFjAKBggqhkjOPQQDAjAwMS4w
      LAYDVQQDEyVDYWRkeSBMb2NhbCBBdXRob3JpdHkgLSAyMDI1IEVDQyBSb290MB4X
      DTI1MTIyMzIzMTExMFoXDTM1MTEwMTIzMTExMFowMDEuMCwGA1UEAxMlQ2FkZHkg
      TG9jYWwgQXV0aG9yaXR5IC0gMjAyNSBFQ0MgUm9vdDBZMBMGByqGSM49AgEGCCqG
      SM49AwEHA0IABNWAL+OmSvNI1twW7CjWtVTj9PH86ejV52Tl/VKtTqacbAgS+TdU
      aaekC0skEI1BNc76lsD84yRydvci1om1vv2jRTBDMA4GA1UdDwEB/wQEAwIBBjAS
      BgNVHRMBAf8ECDAGAQH/AgEBMB0GA1UdDgQWBBShYvNluMWdF4EwkTWJgcBe8Foe
      XzAKBggqhkjOPQQDAgNIADBFAiEAkoloryXWPdw50LtidCzi9lZDScU2Uofpp8ie
      uc1PJgQCIBy3BQIcEh9ChGJ1cIrop43zMA4C9O8HwytFX11YpZnF
      -----END CERTIFICATE-----
    ''
  ];

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
