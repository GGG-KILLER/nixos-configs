{ config, ... }:
{
  jibril.dynamic-ports = [ "keycloak" ];

  age.secrets."keycloak-db-password" = {
    file = ../../../../../secrets/jibril/keycloak/db-password.age;
  };

  services.keycloak = {
    enable = true;
    initialAdminPassword = "changeme";
    settings = {
      hostname = "sso.lan";
      http-enabled = true;
      http-host = "127.0.0.1";
      http-port = config.jibril.ports.keycloak;
      proxy-headers = "xforwarded";
    };
    database = {
      createLocally = false;
      host = "localhost";
      port = config.jibril.ports.postgres;
      name = "keycloak";
      username = "keycloak";
      passwordFile = config.age.secrets."keycloak-db-password".path;
      useSSL = false;
    };
  };

  services.caddy.virtualHosts."sso.lan".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString config.jibril.ports.keycloak}
  '';
}
