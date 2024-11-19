{pkgs, ... }: let
  settings = (pkgs.formats.toml {}).generate "starship.toml" {
    add_newline = false;
    format = ''$nix_shell$directory$git_branch$git_status $character'';

    scan_timeout = 10;

    character = {
      success_symbol = "[λ](green bold)";
      error_symbol = "[λ](red bold)";
    };

    git_branch.format = "[@$branch](underline)";

    git_status = {
      format = "$modified";
      modified = "[*](red bold)";
    };

    directory = {
      format = "$path";
      truncation_length = 3;
      truncate_to_repo = true;
    };

    nix_shell = {
      format = "[$name](blue bold) ";
    };
  };
in pkgs.symlinkJoin {
  name = "starship";
  paths = [ pkgs.starship ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/starship \
      --set STARSHIP_CONFIG ${settings}
  '';
}

