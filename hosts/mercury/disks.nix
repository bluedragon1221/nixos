{
  # TODO: Replace this with disko eventually

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3d80a86b-3268-4209-a833-b531b8bc0ebc";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/45A4-2E5B";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };
}
