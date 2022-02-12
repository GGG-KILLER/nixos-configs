{ config, ... }:

{
  services.grafana = rec {
    enable = true;
    domain = "grafana.shiro.lan";
    rootUrl = "http://${domain}/";
  };

  services.nginx.virtualHosts."grafana.shiro.lan" = {
    locations."/" = {
      proxyPass = with config.services.grafana; "${protocol}://${addr}:${toString port}";
    };
  };
}
