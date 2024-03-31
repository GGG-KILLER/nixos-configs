{config, ...}: {
  # Create user and group so that they exist when we chmod the db password secret.
  users.users.keycloak = {
    name = "keycloak";
    isSystemUser = true;
    group = "keycloak";
  };
  users.groups.keycloak = {
    name = "keycloak";
  };

  services.keycloak = {
    enable = true;

    database = {
      type = "postgresql";
      host = "pgprd.shiro.lan";

      name = "keycloak";
      username = "keycloak";
      passwordFile = config.age.secrets."keycloak/db_password".path;
      useSSL = false;
    };

    settings = {
      hostname = "sso.shiro.lan";
      http-port = 26404;
      https-port = 26405;

      proxy = "edge";
      proxy-headers = "xforwarded";
    };
  };

  modules.services.nginx.virtualHosts."sso.shiro.lan" = {
    ssl = true;
    locations."/".proxyPass = "http://127.0.0.1:26404";
  };
}
