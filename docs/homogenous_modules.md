# Homogenous Nix Modules: Why and How
In the creation of my nixos configuration, I came to a (possibly unique) issue:
many services that I wanted to configure required a "system" piece, and a "home" piece.

For example, in configuring a shell, it makes sense to configure that shell as the default shell for the user in the same place.
However, in standard nixos configuration, you configure the actual shell with home-manager, and the default-ness with nixos.

My solution to this was to create a new way of managing my nixos modules, which I coined "Homogenous Modules."

The idea is as follows: each module contains three parts:
1. a shared `options.nix` file,
2. a nixos part, and
3. a home-manager part (or [Hjem](github.com/feel-co/hjem), in my case).

The `options.nix` file contains _only_ the `options` section of a module.
The nixos part contains the `config` section of the module, as if it was a nixos module.
The home-manager part contains the `config` section of the module, as if it was a home-manager module.

Now, `{imports = [./options.nix ./nixos.nix];}` is a valid nixos module, and
`{imports = [./options.nix ./home.nix];}` is a valid home-manager module.

## Example
Let's implement that shell example from the start, from scratch.
We'll start with with the `options.nix`:
```nix
{lib, ...}: let
  inherit (lib) mkOption mkEnableOption;
in {
  options = {
    collinux.shells = {
      zsh = {
        enable = mkEnableOption "the zsh shell and customizations to it";
        default = mkEnableOption "make zsh the default shell";
      };
      bash = {
        enable = mkEnableOption "the bash shell and customizations to it";
        default = mkEnableOption "make bash the default shell";
      };
    };
  };
  config.assertions = [
    {
      assertion = with collinux.shells; !(zsh.default && bash.default);
      message = "You can only have one default shell!";
    }
  ];
}
```

Here, we define a simple configuration.

In the nixos part, we'll set the default shell:
```nix
{pkgs, config, lib, ...}: let
  cfg = config.collinux.shells;
in {
  users.users."collin".shell =
    if config.zsh.enable
    then pkgs.zsh
    else if config.bash.enable
    then pkgs.bash
    else null;
}
```

And in the home-manager part, we'll set some customization options:
```nix
{pkgs, config, lib, ...}: let
  cfg = config.collinux.shells;

  shellAliases = {
    ll = "ls -l";
    update = "home-manager switch";
  };
in {
  programs.zsh = {
    enable = cfg.zsh.enable;
    syntaxHighlighting.enable = true;
    inherit shellAliases;
  };

  programs.bash = {
    enable = cfg.bash.enable;
    inherit shellAliases;
  };
}
```
