{ config, pkgs, ... }:
{
  jibril.dynamic-ports = [
    "kanidm"
    "sso-acme-http"
  ];

  services.kanidm.package = pkgs.kanidm_1_8;
  services.kanidm.server.enable = true;
  services.kanidm.server.settings = {
    version = "2";

    bindaddress = "127.0.0.1:${toString config.jibril.ports.kanidm}";
    domain = "sso.lan";
    origin = "https://sso.lan";
    tls_chain = "${config.security.acme.certs."sso.lan".directory}/fullchain.pem";
    tls_key = "${config.security.acme.certs."sso.lan".directory}/key.pem";

    online_backup.versions = 7;

    http_client_address_info.x-forward-for = [ "127.0.0.1" ];
  };

  systemd.services.kanidm.after = [ "acme-sso.lan.service" ];
  systemd.services.kanidm.wants = [ "acme-sso.lan.service" ];

  systemd.tmpfiles.rules = [ "d /var/lib/kanidm 1777 root root 10d" ];

  security.acme.certs."sso.lan" = {
    email = "kanidm@${config.networking.fqdn}";
    group = "kanidm";
    listenHTTP = ":${toString config.jibril.ports.sso-acme-http}";
    reloadServices = [ "kanidm.service" ];
  };

  services.caddy.virtualHosts."sso.lan".extraConfig = ''
    reverse_proxy https://127.0.0.1:${toString config.jibril.ports.kanidm} {
      transport http {
        tls_server_name sso.lan
      }
    }
  '';
}
