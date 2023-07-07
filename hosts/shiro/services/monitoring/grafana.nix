{config, ...}: let
  domain = "grafana.shiro.lan";
in {
  services.grafana = {
    enable = true;
    settings.server = {
      inherit domain;
      http_addr = "127.0.0.1";
      root_url = "https://${domain}/";
      enable_gzip = true;
    };
  };

  modules.services.nginx.virtualHosts.${domain} = {
    ssl = true;
    locations."/" = {
      proxyPass = with config.services.grafana.settings.server; "${protocol}://${http_addr}:${toString http_port}";
      extraConfig = ''
        proxy_buffering off;
        proxy_cache off;
      '';
    };
    locations."/api/live/ws" = {
      proxyPass = with config.services.grafana.settings.server; "${protocol}://${http_addr}:${toString http_port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_cache off;
      '';
    };
  };
}
