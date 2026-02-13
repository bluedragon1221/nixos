cfg: {
  networking.extraHosts =
    if cfg.privateUrl != null
    then ''
      127.0.0.1 ${cfg.privateUrl}
    ''
    else "";

  services.caddy.virtualHosts =
    (
      if cfg.publicUrl != null
      then {
        ${cfg.publicUrl}.extraConfig = ''
          reverse_proxy ${cfg.listenAddr}:${toString cfg.port}
        '';
      }
      else {}
    )
    // (
      if cfg.privateUrl != null
      then {
        "${cfg.privateUrl}".extraConfig = ''
          tls internal
          reverse_proxy ${cfg.listenAddr}:${toString cfg.port}
        '';
      }
      else {}
    );
}
