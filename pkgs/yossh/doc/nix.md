# Packing your Yoshi configuration with nix
If you want to declare Yoshi in your nixos configuration, here's how.

First, add Yoshi to your nix flake:
```nix
{
  inputs = {
    yoshi = {
      url = "github:bluedragon1221/yoshi";
      flake = false;
    };
  };
}
```

Next, write a package for Yoshi. This is how I achieved it:
```sh
{
  pkgs,
  inputs,
  ...
}: let
  yossh = pkgs.writeText "yossh.lua" ''
    yoshi = dofile'${inputs.yoshi-lua}/yoshi.lua'

    yoshi.hosts["box"] = yoshi.ssh{
      HostName = "192.168.50.3",
      User = "yoshi"
    }

    yoshi.run(arg)
  '';
in
  pkgs.writeShellScriptBin "yossh" ''
    exec ${pkgs.lua}/bin/lua ${yossh} "$@"
  ''
```

Then add the package in `environment.systemPackages`:
```nix
environment.systemPackages = [
  (pkgs.callPackage ./yossh.nix {inherit inputs;})
]
```
