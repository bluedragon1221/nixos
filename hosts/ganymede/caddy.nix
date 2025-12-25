{
  services.caddy.virtualHosts."https://web.tail7cca06.ts.net".extraConfig = ''
    bind tailscale/web
    root * /var/www/williams_web
    file_server

    handle_path /papa_stories/* {
      root * /var/www/papa_stories
      file_server
    }
  '';
}
