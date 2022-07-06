{ lib, ... }:

with lib;
let
  port = 9925;
in
{
  services.monit = {
    enable = true;
    config = ''
      # Set the daemon poll time
      SET DAEMON 30

      # Set up the HTTP Port
      SET HTTPD PORT ${toString port}
          ALLOW 127.0.0.1
    '';
  };

  security.acme.certs."monit.shiro.lan".email = "monit@shiro.lan";
  services.nginx.virtualHosts."monit.shiro.lan" = {
    enableACME = true;
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
    };
  };
}
