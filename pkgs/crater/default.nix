{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation {
  pname = "crater";
  version = "0.0.1";
  src = ./.;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp crater $out/bin/
    runHook postInstall
  '';

  meta.mainProgram = "crater";
}
