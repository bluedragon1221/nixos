{pkgs ? import <nixpkgs> {system = "x86_64-linux";}, ...}:
pkgs.buildGoModule {
  name = "ganyupload";
  src = ./.;
  vendorHash = null;
}
