{
  system,
  config,
  inputs,
  ...
}: let
  inherit (config.age) secrets;
  wings = inputs.pterodactyl-wings-nix.packages.${system}.pterodactyl-wings;
in {
  virtualisation.oci-containers.containers.pterodactyl-database = {
    image = "mariadb:10.5";
    cmd = ["--default-authentication-plugin=mysql_native_password"];
    volumes = ["pterodactyl-database:/var/lib/mysql/"];
    environment = {
      MYSQL_DATABASE = "panel";
      MYSQL_USER = "pterodactyl";
    };
    environmentFiles = [
      secrets."pterodactyl/db.env".path
    ];
    extraOptions = [
      "--dns=192.168.1.1"
      "--ipc=none"
      "--network=pterodactyl"
      "--network-alias=database"
    ];
  };

  virtualisation.oci-containers.containers.pterodactyl-cache = {
    image = "redis:alpine";
    extraOptions = [
      "--dns=192.168.1.1"
      "--ipc=none"
      "--network=pterodactyl"
      "--network-alias=cache"
    ];
  };

  virtualisation.oci-containers.containers.pterodactyl-panel = {
    image = "ghcr.io/pterodactyl/panel:latest";
    ports = ["10001:80"];
    dependsOn = ["pterodactyl-database" "pterodactyl-cache"];
    volumes = [
      "/zfs-main-pool/data/gaming/pterodactyl/var/:/app/var/"
      "pterodactyl-nginx:/etc/nginx/http.d/"
      "pterodactyl-certs:/etc/letsencrypt/"
      "/zfs-main-pool/data/gaming/pterodactyl/logs/:/app/storage/logs/"
    ];
    environment = {
      # App Settings
      APP_URL = "http://pterodactyl.lan";
      APP_TIMEZONE = config.time.timeZone;
      APP_SERVICE_AUTHOR = "noreply@example.com";
      APP_ENV = "production";
      APP_ENVIRONMENT_ONLY = "false";
      # Email Settings
      # PS: There is no actual SMTP server. Cannot be bothered to set one up.
      MAIL_FROM = "noreply@example.com";
      MAIL_DRIVER = "smtp";
      MAIL_HOST = "mail";
      MAIL_PORT = "1025";
      MAIL_USERNAME = "";
      MAIL_PASSWORD = "";
      MAIL_ENCRYPTION = "true";
      # Redis Settings
      CACHE_DRIVER = "redis";
      SESSION_DRIVER = "redis";
      QUEUE_DRIVER = "redis";
      REDIS_HOST = "cache";
      # DB Settings
      DB_HOST = "database";
      DB_PORT = "3306";
      DB_DATABASE = "panel";
      DB_USERNAME = "pterodactyl";
    };
    environmentFiles = [
      secrets."pterodactyl/panel.env".path
    ];
    extraOptions = [
      "--dns=192.168.1.1"
      "--ipc=none"
      "--network=pterodactyl"
      "--network-alias=panel"
      "--pull=always"
    ];
  };

  security.acme.certs."pterodactyl.lan".email = "pterodactyl@shiro.lan";
  services.nginx.virtualHosts."pterodactyl.lan" = {
    enableACME = true;
    addSSL = true;
    locations."/".proxyPass = "http://127.0.0.1:10001";
  };

  environment.systemPackages = [wings];

  systemd.services.pterodactyl-wings = {
    after = ["docker.service"];
    requires = ["docker.service"];
    partOf = ["docker.service"];
    wantedBy = ["multi-user.target"];

    unitConfig = {
      StartLimitIntervalSec = 180;
      StartLimitBurst = 30;
    };

    serviceConfig = {
      User = "root";
      WorkingDirectory = "/zfs-main-pool/data/gaming/pterodactyl";
      LimitNOFILE = 4096;
      PIDFile = "/var/run/wings/daemon.pid";
      ExecStart = "${wings}/bin/wings --config /zfs-main-pool/data/gaming/pterodactyl/wings-config.yml";

      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
