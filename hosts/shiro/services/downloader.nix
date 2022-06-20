{ ... }:

{
  # This is only for the nginx config of the downloader.
  services.nginx.virtualHosts."downloader.lan" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:9000";
    };
  };
}
