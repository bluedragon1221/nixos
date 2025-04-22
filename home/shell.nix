{pkgs, ...}: {
  catppuccin.fish.enable = true;
  programs.fish = {
    enable = true;
    generateCompletions = true;
    shellAliases = {
      ls = "${pkgs.eza}/bin/eza -A -w 80 --group-directories-first";
      tree = "${pkgs.eza}/bin/eza -T";
      cat = "${pkgs.bat}/bin/bat";
      rg = "${pkgs.ripgrep}/bin/rg";
    };
    shellAbbrs = {
      nh = "nh os switch";
    };
    shellInit = ''
      set fish_greeting
    '';
  };

  # currently starship, fzf, and other catppuccin-nix cfgs use IFD, making them unusable to me. I'll use these modules once they get fixed to not use IFD. https://github.com/catppuccin/nix/issues/392
  catppuccin.fzf.enable = false;
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = false;
    enableBashIntegration = false;
  };

  catppuccin.starship.enable = false;
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = false;
    enableBashIntegration = false;

    settings = {
      format = ''$directory$git_branch$git_status $character'';

      add_newline = false;
      scan_timeout = 10;

      character = {
        success_symbol = "[λ](green bold)";
        error_symbol = "[Σ](red bold)";
      };

      git_branch.format = "[@$branch](underline)";

      git_status = {
        format = "$modified$staged$ahead$behind";
        modified = "[!](red bold)";
        staged = "[+](green bold)";
        ahead = "[](green)";
        behind = "[](red)";
      };

      directory = {
        format = "$path";
        truncation_length = 3;
        truncate_to_repo = true;
      };
    };
  };
}
