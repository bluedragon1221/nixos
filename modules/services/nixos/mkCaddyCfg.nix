cfg: {
  networking.extraHosts =
    if cfg.caddy.local.enable
    then ''
      127.0.0.1 ${cfg.service_name}.collinux
    ''
    else "";

  services.caddy.virtualHosts =
    (
      if cfg.caddy.global.enable && (cfg.root_url != null)
      then {
        ${cfg.root_url}.extraConfig = ''
          ${
            if cfg.caddy.bind_tailscale
            then "bind tailscale/${cfg.service_name}"
            else ""
          }
          reverse_proxy ${cfg.bind_host}:${toString cfg.port}
        '';
      }
      else {}
    )
    // (
      if cfg.caddy.local.enable
      then {
        "${cfg.service_name}.collinux".extraConfig = ''
          tls internal
          reverse_proxy ${cfg.bind_host}:${toString cfg.port}
        '';
      }
      else {}
    );
}
