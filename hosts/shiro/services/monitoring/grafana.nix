{ config, ... }:
{
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.shiro.lan";
      http_addr = "127.0.0.1";
      http_port = config.shiro.ports.grafana;
      root_url = "https://grafana.shiro.lan/";
      enable_gzip = true;
    };
  };

  modules.services.nginx.virtualHosts."grafana.shiro.lan" = {
    ssl = true;
    locations."/" = {
      proxyPass =
        with config.services.grafana.settings.server;
        "${protocol}://${http_addr}:${toString http_port}";
      recommendedProxySettings = true;
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
        proxy_cache off;
      '';
    };
  };
}
