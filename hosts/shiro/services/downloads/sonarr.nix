{config, ...}: {
  systemd.services."${config.virtualisation.oci-containers.backend}-sonarr-network" = let
    backend = config.virtualisation.oci-containers.backend;
  in {
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
    before = ["${backend}-sonarr.service" "${backend}-jackett.service"];
    requiredBy = ["${backend}-sonarr.service" "${backend}-jackett.service"];

    serviceConfig = let
      backendBin = "${config.virtualisation.${backend}.package}/bin/${backend}";
    in {
      Type = "simple";
      RemainAfterExit = "yes";

      ExecStartPre = "-${backendBin} network rm sonarr";
      ExecStart = "${backendBin} network create sonarr";
      ExecStop = "${backendBin} network rm sonarr";
    };
  };

  virtualisation.oci-containers.containers.sonarr = {
    image = "lscr.io/linuxserver/sonarr:latest";
    ports = ["${toString config.shiro.ports.sonarr}:8989"];
    dependsOn = ["jackett"];
    environment = {
      PUID = toString config.users.users.my-sonarr.uid;
      GUID = toString config.users.groups.data-members.gid;
      TZ = config.time.timeZone;
    };
    volumes = [
      "/zfs-main-pool/data/sonarr:/config"
      "/zfs-main-pool/data/animu:/mnt/animu"
      "/zfs-main-pool/data/series:/mnt/series"
      "/zfs-main-pool/data/h:/mnt/h"
    ];
    extraOptions = [
      "--dns=192.168.1.1"
      "--ipc=none"
      "--network=sonarr"
      "--pull=always"
    ];
  };

  virtualisation.oci-containers.containers.jackett = {
    image = "lscr.io/linuxserver/jackett:latest";
    ports = ["${toString config.shiro.ports.jackett}:9117"];
    environment = {
      PUID = toString config.users.users.my-sonarr.uid;
      GUID = toString config.users.groups.data-members.gid;
      TZ = config.time.timeZone;
      AUTO_UPDATE = "true";
    };
    volumes = [
      "/zfs-main-pool/data/jackett:/config"
    ];
    extraOptions = [
      "--dns=192.168.1.1"
      "--ipc=none"
      "--network=sonarr"
      "--pull=always"
    ];
  };

  # NGINX
  modules.services.nginx.virtualHosts = {
    "sonarr.shiro.lan" = {
      ssl = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.shiro.ports.sonarr}";
        recommendedProxySettings = true;
        proxyWebsockets = true;
        sso = true;
      };
    };

    "jackett.shiro.lan" = {
      ssl = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.shiro.ports.jackett}";
        recommendedProxySettings = true;
        proxyWebsockets = true;
        sso = true;
      };
    };
  };
}
