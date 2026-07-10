{ pkgs, config, ... }: {
  age.secrets."bookstack_app.key" = {
    file = ../../../../secrets/jibril/bookstack/app.key.age;
    owner = config.services.bookstack.user;
    inherit (config.services.bookstack) group;
    mode = "0400";
  };

  izuna.dynamic-ports = [ "bookstack" ];

  services.bookstack.enable = true;
  services.bookstack.hostname = "kb.lan";
  services.bookstack.maxUploadSize = "1G";
  services.bookstack.settings.APP_URL = "https://kb.lan";
  services.bookstack.settings.APP_KEY_FILE = config.age.secrets."bookstack_app.key".path;
  services.bookstack.settings.DB_HOST = "localhost";
  services.bookstack.settings.DB_PORT = 3306;
  services.bookstack.settings.DB_USERNAME = "bookstack";
  services.bookstack.settings.DB_DATABASE = "bookstack";
  services.bookstack.settings.DB_SOCKET = "/run/mysqld/mysqld.sock";
  services.bookstack.nginx.listen = [
    {
      addr = "127.0.0.1";
      port = config.izuna.ports.bookstack;
      ssl = false;
    }
  ];

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings.mysqld.character-set-server = "utf8mb4";
    ensureDatabases = [ "bookstack" ];
    ensureUsers = [
      {
        name = "bookstack";
        ensurePermissions = {
          "bookstack.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.caddy.virtualHosts."kb.lan".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString config.izuna.ports.bookstack}
  '';
}
