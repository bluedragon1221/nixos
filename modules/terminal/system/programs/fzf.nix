{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.fzf;
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files.".config/fish/conf.d/fzf.fish".text = ''
        ${pkgs.fzf}/bin/fzf --fish | source
        set -gx FZF_DEFAULT_OPTS "--color bg:#1E1E2E,bg+:#313244,border:#313244,fg:#CDD6F4,fg+:#CDD6F4,header:#F38BA8,hl:#F38BA8,hl+:#F38BA8,info:#CBA6F7,label:#CDD6F4,marker:#B4BEFE,pointer:#F5E0DC,prompt:#CBA6F7,selected-bg:#45475A,spinner:#F5E0DC"
      '';

      packages = [pkgs.fzf];
    };
  }
