{ config, ... }:
{
  systemd.services."${config.virtualisation.oci-containers.backend}-downloader-network" =
    let
      backend = config.virtualisation.oci-containers.backend;
    in
    {
      wantedBy = [ "multi-user.target" ];
      after = [
        "docker.service"
        "docker.socket"
      ];
      before = [
        "${backend}-downloader-backend.service"
        "${backend}-downloader-frontend.service"
      ];
      requiredBy = [
        "${backend}-downloader-backend.service"
        "${backend}-downloader-frontend.service"
      ];

      serviceConfig =
        let
          backendBin = "${config.virtualisation.${backend}.package}/bin/${backend}";
        in
        {
          Type = "simple";
          RemainAfterExit = "yes";

          ExecStartPre = "-${backendBin} network rm downloader";
          ExecStart = "${backendBin} network create downloader";
          ExecStop = "${backendBin} network rm downloader";
        };
    };

  virtualisation.oci-containers.containers.downloader-frontend = {
    image = "docker.lan/downloader/frontend:latest";
    ports = [ "${toString config.shiro.ports.downloader}:8080" ];
    dependsOn = [ "downloader-backend" ];
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
    image = "docker.lan/downloader/backend:latest";
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
  modules.services.nginx.virtualHosts."downloader.lan" = {
    ssl = true;
    locations."/" = {
      recommendedProxySettings = true;
      sso = true;
      proxyPass = "http://127.0.0.1:${toString config.shiro.ports.downloader}";
    };
  };
}
