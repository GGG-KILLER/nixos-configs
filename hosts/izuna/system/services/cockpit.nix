{ ... }:
{
  services.cockpit = {
    enable = true;
    allowed-origins = [
      "https://cp.izuna.lan"
      "wss://cp.izuna.lan"
    ];
    settings.WebService = {
      ProtocolHeader = "X-Forwarded-Proto";
      ForwardedForHeader = "X-Forwarded-For";
    };
  };

  services.caddy.virtualHosts."cp.izuna.lan".extraConfig = "reverse_proxy http://127.0.0.1:9090";
}
