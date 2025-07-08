{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.shells.fish;

  init = ''
    set fish_greeting

    if status is-interactive
      alias cat bat
      set -x BAT_THEME "base16"

      alias ls "${pkgs.eza}/bin/eza -A -w 80 --group-directories-first -I '.git*'"
      alias tree "${pkgs.eza}/bin/eza -T"

      ${pkgs.fzf}/bin/fzf --fish | source
      set -x FZF_DEFAULT_OPTS "--color bg:#1E1E2E,bg+:#313244,border:#313244,fg:#CDD6F4,fg+:#CDD6F4,header:#F38BA8,hl:#F38BA8,hl+:#F38BA8,info:#CBA6F7,label:#CDD6F4,marker:#B4BEFE,pointer:#F5E0DC,prompt:#CBA6F7,selected-bg:#45475A,spinner:#F5E0DC"

      ${pkgs.pay-respects}/bin/pay-respects fish --alias | source

      set -x NH_FLAKE "$HOME/nixos"
    end
  '';
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = {
        ".config/fish/config.fish".text = init;
      };

      packages = with pkgs; [
        fish
        bat
        eza
        fzf
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
