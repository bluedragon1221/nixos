{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.terminal.shells.fish;

  conf = {
    skin = catppuccin_skin;
    verbs = [
      {
        name = "open-code";
        key = "enter";
        execution = "$EDITOR +{line} {file}";
        working_dir = "{root}";
        apply_to = "file";
        leave_broot = true;
      }
    ];
  };

  catppuccin_skin = {
    input = "rgb(205, 214, 244) none";
    selected_line = "none rgb(88, 91, 112)";
    default = "rgb(205, 214, 244) none";
    tree = "rgb(108, 112, 134) none";
    parent = "rgb(116, 199, 236) none";
    file = "none none";

    perm__ = "rgb(186, 194, 222) none";
    perm_r = "rgb(250, 179, 135) none";
    perm_w = "rgb(235, 160, 172) none";
    perm_x = "rgb(166, 227, 161) none";
    owner = "rgb(148, 226, 213) none";
    group = "rgb(137, 220, 235) none";

    dates = "rgb(186, 194, 222) none";

    directory = "rgb(180, 190, 254) none Bold";
    exe = "rgb(166, 227, 161) none";
    link = "rgb(249, 226, 175) none";
    pruning = "rgb(166, 173, 200) none Italic";

    preview_title = "rgb(205, 214, 244) rgb(24, 24, 37)";
    preview = "rgb(205, 214, 244) rgb(24, 24, 37)";
    preview_line_number = "rgb(108, 112, 134) none";
    preview_separator = "rgb(108, 112, 134) none";

    char_match = "rgb(249, 226, 175) rgb(69, 71, 90) Bold Italic";
    content_match = "rgb(249, 226, 175) rgb(69, 71, 90) Bold Italic";
    preview_match = "rgb(249, 226, 175) rgb(69, 71, 90) Bold Italic";

    count = "rgb(249, 226, 175) none";
    sparse = "rgb(243, 139, 168) none";
    content_extract = "rgb(243, 139, 168) none Italic";

    git_branch = "rgb(250, 179, 135) none";
    git_insertions = "rgb(250, 179, 135) none";
    git_deletions = "rgb(250, 179, 135) none";
    git_status_current = "rgb(250, 179, 135) none";
    git_status_modified = "rgb(250, 179, 135) none";
    git_status_new = "rgb(250, 179, 135) none Bold";
    git_status_ignored = "rgb(250, 179, 135) none";
    git_status_conflicted = "rgb(250, 179, 135) none";
    git_status_other = "rgb(250, 179, 135) none";
    staging_area_title = "rgb(250, 179, 135) none";

    flag_label = "rgb(243, 139, 168) none";
    flag_value = "rgb(243, 139, 168) none Bold";

    status_normal = "none rgb(24, 24, 37)";
    status_italic = "rgb(243, 139, 168) rgb(24, 24, 37) Italic";
    status_bold = "rgb(235, 160, 172) rgb(24, 24, 37) Bold";
    status_ellipsis = "rgb(235, 160, 172) rgb(24, 24, 37) Bold";
    status_error = "rgb(205, 214, 244) rgb(243, 139, 168)";
    status_job = "rgb(235, 160, 172) rgb(40, 38, 37)";
    status_code = "rgb(235, 160, 172) rgb(24, 24, 37) Italic";
    mode_command_mark = "rgb(235, 160, 172) rgb(24, 24, 37) Bold";

    help_paragraph = "rgb(205, 214, 244) none";
    help_headers = "rgb(243, 139, 168) none Bold";
    help_bold = "rgb(250, 179, 135) none Bold";
    help_italic = "rgb(249, 226, 175) none Italic";
    help_code = "rgb(166, 227, 161) rgb(49, 50, 68)";
    help_table_border = "rgb(108, 112, 134) none";

    hex_null = "rgb(205, 214, 244) none";
    hex_ascii_graphic = "rgb(250, 179, 135) none";
    hex_ascii_whitespace = "rgb(166, 227, 161) none";
    hex_ascii_other = "rgb(148, 226, 213) none";
    hex_non_ascii = "rgb(243, 139, 168) none";

    file_error = "rgb(251, 73, 52) none";

    purpose_normal = "none none";
    purpose_italic = "rgb(177, 98, 134) none Italic";
    purpose_bold = "rgb(177, 98, 134) none Bold";
    purpose_ellipsis = "none none";

    scrollbar_track = "rgb(49, 50, 68) none";
    scrollbar_thumb = "rgb(88, 91, 112) none";

    good_to_bad_0 = "rgb(166, 227, 161) none";
    good_to_bad_1 = "rgb(148, 226, 213) none";
    good_to_bad_2 = "rgb(137, 220, 235) none";
    good_to_bad_3 = "rgb(116, 199, 236) none";
    good_to_bad_4 = "rgb(137, 180, 250) none";
    good_to_bad_5 = "rgb(180, 190, 254) none";
    good_to_bad_6 = "rgb(203, 166, 247) none";
    good_to_bad_7 = "rgb(250, 179, 135) none";
    good_to_bad_8 = "rgb(235, 160, 172) none";
    good_to_bad_9 = "rgb(243, 139, 168) none";
  };
in
  lib.mkIf cfg.enable {
    hjem.users."${config.collinux.user.name}" = {
      files = {
        ".config/broot/conf.toml" = {
          generator = (pkgs.formats.toml {}).generate "conf.toml";
          value = conf;
        };

        ".config/fish/conf.d/broot.fish".text = lib.mkIf config.collinux.terminal.shells.fish.enable ''
          ${pkgs.broot}/bin/broot --print-shell-function fish | source
        '';
      };

      packages = [pkgs.broot];
    };
  }
