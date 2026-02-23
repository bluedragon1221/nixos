cfg: let
  caddyConfig =
    if cfg ? reverseProxy && cfg.reverseProxy == true
    then ''reverse_proxy ${cfg.listenAddr}:${toString cfg.port}''
    else cfg.manualCaddyConfig;
in {
  networking.extraHosts =
    if cfg.privateUrl != null
    then "127.0.0.1 ${cfg.privateUrl}"
    else "";

  services.caddy.virtualHosts =
    (
      if cfg.publicUrl != null
      then {
        ${cfg.publicUrl}.extraConfig = caddyConfig;
      }
      else {}
    )
    // (
      if cfg.privateUrl != null
      then {
        "${cfg.privateUrl}".extraConfig = ''
          tls internal
          ${caddyConfig}
        '';
      }
      else {}
    );
}
