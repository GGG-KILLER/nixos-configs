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

  services.caddy.virtualHosts."cp.shiro.lan".extraConfig = "reverse_proxy http://127.0.0.1:9090";
}
