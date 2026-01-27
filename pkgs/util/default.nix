{pkgs ? import <nixpkgs> {system = "x86_64-linux";}, ...}: let
  lsdbus-src = pkgs.fetchFromGitHub {
    owner = "kmarkus";
    repo = "lsdbus";
    rev = "6f80930248110927d1f898966544eec202ea3550";
    hash = "sha256-N/VCjrI7RolHV0ya1U+YTLGAWv8+WNz2nobaGxdR1wQ=";
  };

  lsdbus = pkgs.stdenv.mkDerivation {
    pname = "lsdbus";
    version = "scm-3";
    src = lsdbus-src;
    nativeBuildInputs = with pkgs; [cmake gnumake pkg-config systemdLibs minixml lua5_4];
    cmakeFlags = ["-DCONFIG_LUA_VER=5.4"];
  };

  lua =
    pkgs.runCommand "lua-env" {
      buildInputs = with pkgs; [lua5_4];
      nativeBuildInputs = [pkgs.makeWrapper];
    } ''
      mkdir -p $out/bin
      install -D -m 755 ${pkgs.lua5_4}/bin/lua $out/bin/lua
      wrapProgram $out/bin/lua \
        --prefix LUA_PATH \; '?.lua;?/init.lua' \
        --prefix LUA_PATH \; '${lsdbus}/share/lua/5.4/?.lua' \
        --prefix LUA_PATH \; '${lsdbus}/share/lua/5.4/?/init.lua' \
        --prefix LUA_CPATH \; '${lsdbus}/lib/lua/5.4/?.so'
    '';
in
  pkgs.stdenv.mkDerivation {
    pname = "util.lua";
    version = "1.0.0";
    src = ./.;
    buildInputs = [pkgs.brightnessctl];
    nativeBuildInputs = [pkgs.makeWrapper];

    buildPhase = ''
      mkdir -p $out/{bin,lib}
      substitute $src/util.lua $out/bin/util.lua --replace-fail @lua@ ${lua} --replace-fail @out@ $out
      cp -r $src/util $out/lib/util
      chmod +x $out/bin/util.lua
    '';
  }
