```sh
nixos-rebuild build-vm --flake .#collinux
```


A host config has many parts
- user environment config (home-manager)
- system config
- hardware config (facter)
  - disks config (disko or manual)

## Dream hosts/config.nix
```nix
collinux = {
  user = {
    fullName = "";
    name = "";
    email = "";
    password = "";
  };

  theme = "";

  desktop = {
    programs = {};
  };

  terminal = {
    programs = {};
  };

  boot = {};

  extraNixosModules = [];
  extraHomeModules = [];
};
```
