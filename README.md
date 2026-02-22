# `bluedragon1221/nixos`
Cool things:

- Using [hjem](https://github.com/feel-co/hjem) over [home-manager](https://github.com/nix-community/home-manager)
- Features an [awesome tmux configuration](https://github.com/bluedragon1221/tmux-tsunami)
- Deployments over ssh using [deploy-rs](https://github.com/serokell/deploy-rs)
- Automatic secret decryption with ssh keys using [agenix](https://github.com/ryantm/agenix)
- Fully declarative self-hosted services, including:
  - [Headscale](./modules/services/nixos/selfhost/headscale.nix)
  - [AdGuard Home](./modules/services/nixos/selfhost/adguard.nix)
  - [Forgejo](./modules/services/nixos/selfhost/forgejo.nix)
  - [Navidrome](./modules/services/nixos/selfhost/navidrome.nix)
  - ... all with configurable [caddy-tailscale](https://github.com/tailscale/caddy-tailscale) integration
- [Homogenous modules](./docs/homogenous_modules.md)

# Hosts
## [Mercury](./hosts/mercury)
- Device: Lenovo Thinkpad X1 Carbon Gen 6
- OS: NixOS
- DE/Compositor: Sway (or Niri, I can't decide)

Goes everywhere with me. Used for programming, school, and browsing the web

## [Jupiter](./hosts/jupiter)
- Device: HP ENVY Desktop
- OS: NixOS (dual booted with Windows 11 LTSC IoT Enterprise)
- DE/Compositor: GNOME

Used for heavier tasks, like gaming and music production

## [Ganymede](./hosts/ganymede)
- Device: Lenovo Yoga 730 (broken screen)
- OS: NixOS
- DE/Compositor: none

Hosts my family's webserver, personal Headscale instance, and a few other self-hosted services over my tailnet

## Terra
- Device: Samsung S20 Ultra
- OS: Android

My phone. Used for communication, reading Hacker News, and whatever else.

## Io
- Device: Raspberry PI Zero 2 W
- OS: Alpine Linux
- DE/Compositor: none

Low-power device used as a Forgejo actions runner
