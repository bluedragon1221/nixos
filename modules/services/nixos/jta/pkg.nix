{pkgs ? import <nixpkgs> {system = "x86_64-linux";}, ...}:
pkgs.buildGoModule {
  name = "jta";
  src = ./.;
  vendorHash = "sha256-aeJYO52ALbGxyTFPw6eGCmPlmuCvbXEoX9gcXatN29E=";
}
