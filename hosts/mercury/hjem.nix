{
  pkgs,
  lib,
  ...
}: let
  rust-shell = let
    rustProfile = pkgs.buildEnv {
      name = "rust-profile";
      paths = with pkgs; [rustc cargo rust-analyzer gcc];
    };
  in
    pkgs.writeShellScriptBin "rust-shell" ''
      export PATH="${rustProfile}/bin:$PATH"
      export RUST_BACKTRACE=1
      exec $SHELL
    '';

  py-shell = let
    pythonProfile = pkgs.python314.withPackages (ps:
      with ps; [
        numpy
        matplotlib
        pandas
        jupyter
        ipython
      ]);
  in
    pkgs.writeShellScriptBin "py-shell" ''
      export PATH="${pythonProfile}/bin:$PATH"
      export PYTHONSTARTUP=""
      exec $SHELL
    '';

  smallObsidian = let
    pname = "obsidian";
    version = "1.13.7";
  in
    pkgs.stdenv.mkDerivation {
      inherit pname version;

      src = pkgs.fetchurl {
        url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/obsidian-${version}.tar.gz";
        hash = "sha256-08vjdcv6QCTbGRC5gZFkn0E0xcSK7l5gtudxOYfc2yg=";
      };
      nativeBuildInputs = with pkgs; [
        autoPatchelfHook
        makeWrapper
        imagemagick
        asar
      ];
      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin

        # Mark Obsidian's app:// scheme `corsEnabled` to fix the internal PDF
        # viewer; see https://github.com/NixOS/nixpkgs/pull/525772 for details.
        # Remove once upstream registers the scheme with `corsEnabled`.
        asar extract resources/app.asar app-src
        substituteInPlace app-src/main.js \
          --replace-fail "supportFetchAPI: true," "supportFetchAPI: true, corsEnabled: true,"
        asar pack app-src resources/app.asar

        makeWrapper ${pkgs.electron}/bin/electron $out/bin/obsidian \
          --add-flags $out/share/obsidian/app.asar \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-wayland-ime=true --wayland-text-input-version=3}}"
        install -m 755 -D obsidian-cli $out/bin/obsidian-cli
        install -m 444 -D resources/app.asar $out/share/obsidian/app.asar
        install -m 444 -D resources/obsidian.asar $out/share/obsidian/obsidian.asar
        runHook postInstall
      '';
    };
in {
  packages = with pkgs; [
    anki
    libreoffice-qt
    musescore
    vscodium
    smallObsidian

    noctalia-shell

    mpv
    irssi

    (pkgs.callPackage ../../pkgs/yo {})

    rust-shell
    py-shell
  ];
}
