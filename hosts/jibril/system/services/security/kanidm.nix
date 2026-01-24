{ config, pkgs, ... }:
{
  jibril.dynamic-ports = [
    "kanidm"
    "sso-acme-http"
  ];

  services.kanidm.enableServer = true;
  services.kanidm.package = pkgs.kanidm_1_8;
  services.kanidm.serverSettings = {
    version = "2";

    bindaddress = "127.0.0.1:${toString config.jibril.ports.kanidm}";
    domain = "sso.lan";
    origin = "https://sso.lan";
    tls_chain = "/var/lib/kanidm/fullchain.pem";
    tls_key = "/var/lib/kanidm/key.pem";

    online_backup.versions = 7;

    http_client_address_info.x-forward-for = [ "127.0.0.1" ];
  };

  systemd.tmpfiles.rules = [ "d /var/lib/kanidm 1777 root root 10d" ];

  security.acme.certs."sso.lan" = {
    email = "sso@${config.networking.fqdn}";
    listenHTTP = ":${toString config.jibril.ports.sso-acme-http}";
    postRun = ''
      set -xeuo pipefail

      cp fullchain.pem /var/lib/kanidm/fullchain.pem;
      cp key.pem /var/lib/kanidm/key.pem;

      chmod 440 /var/lib/kanidm/fullchain.pem /var/lib/kanidm/key.pem;
      chown root:kanidm /var/lib/kanidm/fullchain.pem /var/lib/kanidm/key.pem;

      systemctl restart kanidm.service
    '';
  };

  services.caddy.virtualHosts."sso.lan" = {
    useACMEHost = "sso.lan";
    extraConfig = "reverse_proxy https://127.0.0.1:${toString config.jibril.ports.kanidm}";
  };
}
