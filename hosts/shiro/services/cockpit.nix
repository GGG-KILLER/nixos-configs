{ ... }:
{
  services.cockpit = {
    enable = true;
    allowed-origins = [
      "https://cp.shiro.lan"
      "wss://cp.shiro.lan"
    ];
    settings.WebService = {
      ProtocolHeader = "X-Forwarded-Proto";
      ForwardedForHeader = "X-Forwarded-For";
    };
  };

  modules.services.nginx.virtualHosts."cp.shiro.lan" = {
    ssl = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9090";
      recommendedProxySettings = true;
      proxyWebsockets = true;
      extraConfig = ''
        gzip off;
      '';
    };
  };
}
