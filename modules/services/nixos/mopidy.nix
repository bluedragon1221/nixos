{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.collinux.services.mopidy;
in {
  config = lib.mkIf cfg.enable {
    services.mopidy = {
      enable = true;
      extensionPackages = with pkgs; [mopidy-youtube mopidy-mpd mopidy-local];
      settings = {
        mpd = {
          enabled = true;
          hostname = "0.0.0.0";
          port = cfg.port;
        };

        # disable default plugins
        file.enabled = false;
        http.enabled = false; # only use mpd

        local = {
          enabled = true;
          media_dir = "/media/library/music";
        };

        youtube = {
          enabled = true;
          allow_cache = true;
          musicapi_enabled = true;
          youtube_dl_package = "yt_dlp";
          autoplay_enabled = true;
          strict_autoplay = false;
          search_results = 15;
        };
      };
    };
  };
}
