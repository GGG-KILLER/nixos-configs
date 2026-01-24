{ ... }:
{
  services.cockpit = {
    enable = true;
    allowed-origins = [
      "https://cp.jibril.lan"
      "wss://cp.jibril.lan"
    ];
    settings.WebService = {
      ProtocolHeader = "X-Forwarded-Proto";
      ForwardedForHeader = "X-Forwarded-For";
    };
  };

  services.caddy.virtualHosts."cp.shiro.lan".extraConfig = "reverse_proxy http://127.0.0.1:9090";
}
