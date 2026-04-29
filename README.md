# `bluedragon1221/nixos`
Cool things:

- Using [hjem](https://github.com/feel-co/hjem) over [home-manager](https://github.com/nix-community/home-manager)
- Deployments over ssh using [deploy-rs](https://github.com/serokell/deploy-rs)
- Automatic secret decryption with ssh keys using [agenix](https://github.com/ryantm/agenix)
- Fully declarative self-hosted services, including:
  - [cgit](../tree/modules/services/nixos/cgit/default.nix)
  - [GoAccess](../tree/modules/services/nixos/goaccess.nix)
  - [Polaris](../tree/modules/services/nixos/polaris.nix)
  - [qBittorrent](../tree/modules/services/nixos/qbittorrent.nix)
- [Homogenous modules](../about/docs/homogenous_modules.md)

# Hosts
## [Mercury](../tree/hosts/mercury)
- Device: Lenovo Thinkpad X1 Carbon Gen 6
- OS: NixOS
- DE/Compositor: Sway (or Niri, I can't decide)

Goes everywhere with me. Used for programming, school, and browsing the web

## [Ganymede](../tree/hosts/ganymede)
- Device: Lenovo Yoga 730 (broken screen)
- OS: NixOS
- DE/Compositor: none

Hosts my family's webserver and a few other self-hosted services over ssh

## Terra
- Device: Samsung S20 Ultra
- OS: Android

My phone. Used for communication, reading Hacker News, whatever else.

## Io
- Device: Raspberry PI Zero 2 W
- OS: Alpine Linux
- DE/Compositor: none

Low-power device, currently unused
