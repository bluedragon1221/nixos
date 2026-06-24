{
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./disks.nix
    ./battery.nix

    inputs.nixos-facter-modules.nixosModules.facter
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  facter.reportPath = ./facter.json;

  services.dbus.implementation = "broker";
  services.upower.enable = true;

  environment.defaultPackages = lib.mkForce []; # im not a noob

  programs.ssh.extraConfig = ''
    Host ganymede
      HostName williamsfam.us.com
      Port 22
  '';

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  users.users.collin = {
    extraGroups = ["podman"];
    subGidRanges = [
      {
        count = 65536;
        startGid = 100000;
      }
    ];
    subUidRanges = [
      {
        count = 65536;
        startUid = 100000;
      }
    ];
  };
  virtualisation.waydroid = {
    package = pkgs.waydroid-nftables;
    enable = true;
  };

  programs.kdeconnect.enable = true;

  services.autossh.sessions = [
    {
      name = "ganymede";
      user = "collin";
      monitoringPort = 20000;
      extraArguments = "-N -D 9090 collin@ganymede";
    }
  ];
  boot.supportedFilesystems."fuse.sshfs" = true;
  fileSystems."/home/collin/ganymede" = {
    device = "collin@ganymede:/media";
    fsType = "fuse.sshfs";
    options = [
      "identityfile=/home/collin/.ssh/id_ed25519"
      "idmap=user"
      "x-systemd.automount" # mount the filesystem automatically on first access
      "allow_other" # don't restrict access to only the user which `mount`s it (because that's probably systemd who mounts it, not you)
      "user" # allow manual `mount`ing, as ordinary user.
    ];
  };

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

  virtualisation.vmVariant = {
    virtualisation.diskSize = 8192;
  };
}
