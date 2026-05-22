{pkgs, ...}: let
  version = "1.10.3";
in
  pkgs.stdenv.mkDerivation {
    pname = "obsidian";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/obsidian-${version}.tar.gz";
      hash = "sha256-zI8CEhHt6VIGfh4kj4YxdfxJPJaf7mhMVnM45TmaoI0=";
    };
    nativeBuildInputs = [pkgs.makeWrapper];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      makeWrapper ${pkgs.electron_39}/bin/electron $out/bin/obsidian \
        --add-flags $out/share/obsidian/app.asar \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime=true --wayland-text-input-version=3}}"
      install -m 444 -D resources/app.asar $out/share/obsidian/app.asar
      install -m 444 -D resources/obsidian.asar $out/share/obsidian/obsidian.asar
      runHook postInstall
    '';
  }
