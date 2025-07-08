{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.shells.fish;

  init = ''
    set fish_greeting

    pay-respects fish --alias | source
  '';
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = {
        ".config/fish/config.fish".text = init;
      };

      packages = with pkgs; [
        fish
        ripgrep
        fd
        moreutils
        zip
        unzip
        btop
        jq
        pay-respects
      ];
    };
  }
