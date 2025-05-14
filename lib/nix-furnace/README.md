# `nix-furnace`
my homebrewed library for defining nix machines

Features:
- Homogenous modules: each module contains a home part, a system part, and a shared `options.nix`
- Path-based: All modules in `modules/` are imported automatically
- Exclusive: Only supports single-user nixos machines running home-manager
