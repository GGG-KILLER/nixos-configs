{config, ...}: {
  services.grafana = rec {
    enable = true;
    domain = "grafana.shiro.lan";
    rootUrl = "http://${domain}/";
  };

  security.acme.certs."grafana.shiro.lan".email = "grafana@shiro.lan";
  services.nginx.virtualHosts."grafana.shiro.lan" = {
    enableACME = true;
    addSSL = true;
    locations."/" = {
      proxyPass = with config.services.grafana; "${protocol}://${addr}:${toString port}";
    };
  };
}
