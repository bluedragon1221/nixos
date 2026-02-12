cfg: {
  networking.extraHosts =
    if cfg.privateURL
    then ''
      127.0.0.1 ${cfg.privateURL}
    ''
    else "";

  services.caddy.virtualHosts =
    (
      if cfg.publicURL
      then {
        ${cfg.publicURL}.extraConfig = ''
          ${
            if cfg.caddy.bind_tailscale
            then "bind tailscale/${cfg.service_name}"
            else ""
          }
          reverse_proxy ${cfg.listenAddr}:${toString cfg.port}
        '';
      }
      else {}
    )
    // (
      if cfg.caddy.privateURL
      then {
        "${cfg.privateURL}.collinux".extraConfig = ''
          tls internal
          reverse_proxy ${cfg.listenAddr}:${toString cfg.port}
        '';
      }
      else {}
    );
}
