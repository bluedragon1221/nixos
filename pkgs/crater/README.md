# Crater
this is a completely vibecoded c program with no dependencies that creates network namespaces using the kernel api and systemd-networkd.

- `up` creates the namespace
  - `--subnet` is the ip address range that the namespace sits on
  - `--masquerade` configures masquerading with networkd so that services in the namespace can reach the internet
- `down` deletes the namespace

examples in ../../modules/services/nixos/service_modules/crater-sidecar.nix

:)
