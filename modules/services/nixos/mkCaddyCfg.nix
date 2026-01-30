cfg: {
  services.caddy =
    if cfg.caddy.enable
    then {
      virtualHosts.${cfg.root_url}.extraConfig = ''
        ${
          if cfg.caddy.bind_tailscale
          then "bind tailscale/${cfg.service_name}"
          else ""
        }
        reverse_proxy ${cfg.bind_host}:${toString cfg.port}
      '';
    }
    else {};
}
