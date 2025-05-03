{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  imports = [
    ./emulators/foot.nix
    ./emulators/blackbox.nix

    ./programs/tmux
    ./programs/starship
    ./programs/bat.nix
    ./programs/helix.nix
    ./programs/eza.nix
    ./programs/fzf.nix

    ./shells/fish.nix
    ./shells/bash.nix
  ];

  options = {
    collinux.terminal = {
      theme = mkOption {
        type = types.enum ["catppuccin" "gtk"];
      };
    };
  };

  config = {
    home.packages = with pkgs; [
      unzip
      zip
      ripgrep
      fd
      moreutils
      jq
      btop
    ];
  };
}
