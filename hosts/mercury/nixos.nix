{inputs, ...}: {
  imports = [
    ./disks.nix
    ./battery.nix

    ./wireguard.nix

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

  # required for vm testing
  virtualisation.vmVariant.virtualisation.diskSize = 8192;
}
