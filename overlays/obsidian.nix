{pkgs, ...}: let
  pname = "obsidian";
  version = "1.8.4";

  src = pkgs.fetchurl {
    url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/obsidian-${version}.tar.gz";
    hash = "sha256-bvmvzVyHrjh1Yj3JxEfry521CMX3E2GENmXddEeLwiE=";
  };
in
  pkgs.stdenv.mkDerivation {
    inherit pname version src;
    nativeBuildInputs = with pkgs; [makeWrapper imagemagick];
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      makeWrapper ${pkgs.electron}/bin/electron $out/bin/obsidian \
        --add-flags $out/share/obsidian/app.asar \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime=true}}"
      install -m 444 -D resources/app.asar $out/share/obsidian/app.asar
      install -m 444 -D resources/obsidian.asar $out/share/obsidian/obsidian.asar
      runHook postInstall
    '';
  }
