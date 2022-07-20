{config, ...}: {
  virtualisation.oci-containers.containers.downloader-frontend = {
    image = "shiro.lan:5000/downloader/frontend:latest";
    ports = ["9000:8080"];
    dependsOn = ["downloader-backend"];
    extraOptions = [
      "--cap-drop=ALL"
      "--dns=192.168.1.1"
      "--ipc=none"
      "--network=downloader"
      "--network-alias=frontend"
      "--pull=always"
    ];
  };

  virtualisation.oci-containers.containers.downloader-backend = {
    image = "shiro.lan:5000/downloader/backend:latest";
    user = "downloader:data-members";
    volumes = [
      "pgo:/app/PGO"
      "/zfs-main-pool/data/animu:/mnt/animu"
      "/zfs-main-pool/data/h:/mnt/h"
      "/zfs-main-pool/data/etc:/mnt/etc"
    ];
    environment = {
      ConnectionStrings__Main = config.my.secrets.downloader.connection-string;
    };
    extraOptions = [
      "--cap-drop=ALL"
      "--dns=192.168.1.1"
      "--ipc=none"
      "--network=downloader"
      "--network-alias=backend"
      "--pull=always"
    ];
  };

  # This is only for the nginx config of the downloader.
  security.acme.certs."downloader.lan".email = "downloader@shiro.lan";
  services.nginx.virtualHosts."downloader.lan" = {
    enableACME = true;
    addSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9000";
    };
  };
}
