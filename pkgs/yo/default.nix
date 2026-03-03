{pkgs, ...}: let
  yo = pkgs.writeText "yo.rb" ''
    require '${./nixos.rb}'

    FLAKE_PATH = "/home/collin/nixos"

    case ARGV[0]
      when "deploy", "dep"
        hostname = ARGV[1] or abort "must specify hostname to build"
        ssh_host = ARGV[2] or abort "must specify ssh host to target"

        store_path = Nix.build_configuration(
          flake_path: FLAKE_PATH,
          hostname: hostname
        )
        Nix.switch_to_configuration_remote(store_path: store_path, ssh_host: ssh_host, use_magic_rollback: true)
      when "switch", "sw"
        store_path = Nix.build_configuration(
          flake_path: FLAKE_PATH,
          hostname: `hostname`.chomp
        )
        Nix.switch_to_configuration(
          store_path: store_path,
          verb: "switch",
          sudo_cmd: "run0 --background="
        )
      when "boot"
        store_path = Nix.build_configuration(
          flake_path: FLAKE_PATH,
          hostname: `hostname`.chomp
        )
        Nix.switch_to_configuration(
          store_path: store_path,
          verb: "boot",
          sudo_cmd: "run0 --background="
        )
      when "test"
        store_path = Nix.build_configuration(
          flake_path: FLAKE_PATH,
          hostname: `hostname`.chomp
        )
        Nix.switch_to_configuration(
          store_path: store_path,
          verb: "test",
          sudo_cmd: "run0 --background="
        )
      when "build"
        hostname = ARGV[1] or `hostname`.chomp

        Nix.build_configuration(
          flake_path: FLAKE_PATH,
          hostname: hostname
        )
    end
  '';
in
  pkgs.writeShellScriptBin "yo" ''
    exec ${pkgs.ruby}/bin/ruby ${yo} "$@"
  ''
