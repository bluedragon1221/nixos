_: {
  # following configuration is added only when building VM with build-vm
  virtualisation.vmVariant = {
    # "nixpkgs".hostPlatform = "x86_64-linux";
    virtualisation = {
      memorySize = 2048; # Use 2048MiB memory.
      cores = 3;
      graphics = true;
    };
  };
}
