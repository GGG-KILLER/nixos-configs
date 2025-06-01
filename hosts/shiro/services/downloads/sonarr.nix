{ lib, config, ... }:
{
  config = lib.mkIf (!config.cost-saving.enable || !config.cost-saving.disable-downloaders) {
    services.sonarr.enable = true;
    services.sonarr.user = "my-sonarr";
    services.sonarr.group = "data-members";
    services.sonarr.dataDir = "/var/lib/sonarr";
    services.sonarr.settings = {
      update.mechanism = "external";
      server = {
        port = config.shiro.ports.sonarr;
        bindaddress = "127.0.0.1";
      };
      log.analyticsEnabled = false;
    };

    services.jackett.enable = true;
    services.jackett.user = "my-sonarr";
    services.jackett.group = "data-members";
    services.jackett.dataDir = "/var/lib/jackett";
    services.jackett.port = config.shiro.ports.jackett;

    # NGINX
    modules.services.nginx.virtualHosts = {
      "sonarr.shiro.lan" = {
        ssl = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.shiro.ports.sonarr}";
          recommendedProxySettings = true;
          proxyWebsockets = true;
          sso = true;
        };
      };

      "jackett.shiro.lan" = {
        ssl = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.shiro.ports.jackett}";
          recommendedProxySettings = true;
          proxyWebsockets = true;
          sso = true;
        };
      };
    };
  };
}
