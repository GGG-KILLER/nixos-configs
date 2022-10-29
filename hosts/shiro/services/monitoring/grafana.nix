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

  security.acme.certs."grafana.shiro.lan".email = "grafana@shiro.lan";
  services.nginx.virtualHosts."grafana.shiro.lan" = {
    enableACME = true;
    addSSL = true;
    locations."/" = {
      proxyPass = with config.services.grafana.settings.server; "${protocol}://${http_addr}:${toString http_port}";
    };
  };
}
