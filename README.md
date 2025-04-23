```sh
nixos-rebuild build-vm --flake .#collinux
```


A host config has many parts
- user environment config (home-manager)
- system config
- hardware config (facter)
  - disks config (disko or manual)
