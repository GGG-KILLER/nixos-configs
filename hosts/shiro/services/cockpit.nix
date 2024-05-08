{...}: {
  services.cockpit = {
    enable = true;
    settings.WebService = {
      Origins = "https://cp.shiro.lan wss://cp.shiro.lan";
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
