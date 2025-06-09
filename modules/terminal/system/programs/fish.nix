{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.shells.fish;

  init = pkgs.writeText "config.fish" ''
    set fish_greeting

    function starship_transient_prompt_func
      ${pkgs.starship}/bin/starship module character
    end

    if status is-interactive
      alias cat bat

      alias eza "eza -A -w 80 --group-directories-first -I '.git*'"
      alias ls eza
      alias tree "ls -T"

      ${pkgs.fzf}/bin/fzf --fish | source
      ${pkgs.starship}/bin/starship init fish | source

      enable_transience

      # env vars
      set -x EDITOR hx
      set -x NH_FLAKE "$HOME/nixos"

      set -x BAT_THEME "base16"
      set -x FZF_DEFAULT_OPTS "--color bg:#1E1E2E,bg+:#313244,border:#313244,fg:#CDD6F4,fg+:#CDD6F4,header:#F38BA8,hl:#F38BA8,hl+:#F38BA8,info:#CBA6F7,label:#CDD6F4,marker:#B4BEFE,pointer:#F5E0DC,prompt:#CBA6F7,selected-bg:#45475A,spinner:#F5E0DC"
    end
  '';
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = {
        ".config/fish/config.fish".source = init;
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
      ];
    };
  }
