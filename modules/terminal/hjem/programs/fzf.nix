{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.programs.fzf;
in
  lib.mkIf cfg.enable {
    files =
      lib.optionalAttrs config.collinux.terminal.shells.fish.enable (with config.collinux.palette; {
        ".config/fish/conf.d/fzf.fish".text = ''
          fzf --fish | source
          set -Ux FZF_DEFAULT_OPTS "$FZF_NON_COLOR_OPTS"\
          " --color=bg+:#${base01},bg:#${base00},spinner:#${base12},hl:#${base13}"\
          " --color=fg:#${base04},header:#${base13},info:#${base10},pointer:#${base12}"\
          " --color=marker:#${base12},fg+:#${base06},prompt:#${base10},hl+:#${base13}"
        '';
      })
      // (lib.optionalAttrs config.collinux.terminal.shells.bash.enable (with config.collinux.palette; {
        ".config/bash/conf.d/fzf.bash".text = ''
          eval "$(fzf --bash)"
          export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS"\
          " --color=bg+:#${base01},bg:#${base00},spinner:#${base12},hl:#${base13}"\
          " --color=fg:#${base04},header:#${base13},info:#${base10},pointer:#${base12}"\
          " --color=marker:#${base12},fg+:#${base06},prompt:#${base10},hl+:#${base13}"
        '';
      }));

    packages = [pkgs.fzf];
  }
