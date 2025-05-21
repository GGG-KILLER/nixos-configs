{ pkgs, config, ... }:
let
  # nix run nixpkgs#nix-prefetch-docker -- --image-name ghcr.io/goauthentik/server --image-tag 2025.4.1 --arch amd64 --os linux --quiet
  imageFile = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/goauthentik/server";
    imageDigest = "sha256:19158b9331f2a514c063b0ab0ac884e751cc9fddb42cfc8c0688b0082cf029cc";
    hash = "sha256-t9KliMmu0eqwroBG/SuHnc07txQ9peh1i8E50UjhU4A=";
    finalImageName = "ghcr.io/goauthentik/server";
    finalImageTag = "2025.4.1";
  };

  image = "${imageFile.imageName}:${imageFile.imageTag}";
in
{
  systemd.services."${config.virtualisation.oci-containers.backend}-authentik-network" =
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
        "${backend}-authentik-redis.service"
        "${backend}-authentik-server.service"
        "${backend}-authentik-worker.service"
        "${backend}-authentik-ldap.service"
      ];
      requiredBy = [
        "${backend}-authentik-redis.service"
        "${backend}-authentik-server.service"
        "${backend}-authentik-worker.service"
        "${backend}-authentik-ldap.service"
      ];

      serviceConfig =
        let
          backendBin = "${config.virtualisation.${backend}.package}/bin/${backend}";
        in
        {
          Type = "simple";
          RemainAfterExit = "yes";

          ExecStartPre = "-${backendBin} network rm authentik";
          ExecStart = "${backendBin} network create authentik";
          ExecStop = "${backendBin} network rm authentik";
        };
    };

  virtualisation.oci-containers.containers =
    let
      authentikEnv = {
        AUTHENTIK_INSECURE = "true";

        AUTHENTIK_POSTGRESQL__HOST = "pgprd.shiro.lan";
        AUTHENTIK_POSTGRESQL__NAME = "authentik";
        AUTHENTIK_POSTGRESQL__USER = "authentik";

        AUTHENTIK_REDIS__HOST = "authentik-redis";

        # AUTHENTIK_STORAGE__MEDIA__BACKEND = "s3";
        # AUTHENTIK_STORAGE__MEDIA__S3__REGION = "home-1";
        # AUTHENTIK_STORAGE__MEDIA__S3__BUCKET_NAME = "authentik";
        # AUTHENTIK_STORAGE__MEDIA__S3__ENDPOINT = "https://s3.shiro.lan/";
        # AUTHENTIK_STORAGE__MEDIA__S3__CUSTOM_DOMAIN = "s3.shiro.lan/authentik";
      };
    in
    {
      authentik-redis = {
        imageFile = pkgs.dockerTools.pullImage {
          imageName = "docker.io/library/redis";
          imageDigest = "sha256:62b5498c91778f738f0efbf0a6fd5b434011235a3e7b5f2ed4a2c0c63bb1c786";
          hash = "sha256-fB5EfmkroIEcUHygKVZJGT2zvXMwN8Q1UlKF340qt0A=";
          finalImageName = "docker.io/library/redis";
          finalImageTag = "alpine";
        };
        image = "docker.io/library/redis:alpine";
        cmd = [
          "--save"
          "60"
          "1"
          "--loglevel"
          "warning"
        ];
        volumes = [ "/var/lib/authentik/redis:/data" ];
        extraOptions = [
          "--dns=192.168.1.1"
          "--network=authentik"
        ];
      };

      authentik-server = {
        inherit imageFile image;
        cmd = [ "server" ];
        environment = authentikEnv;
        environmentFiles = [ config.age.secrets."authentik/authentik.env".path ];
        volumes = [
          "/var/lib/authentik/media:/media"
          "/var/lib/authentik/templates:/templates"
        ];
        ports = [
          "${toString config.shiro.ports.authentik}:9000"
          "${toString config.shiro.ports.authentik-ssl}:9443"
        ];
        dependsOn = [ "authentik-redis" ];
        extraOptions = [
          "--dns=192.168.1.1"
          "--network=authentik"
        ];
      };

      authentik-worker = {
        inherit imageFile image;
        user = "root:root";
        cmd = [ "worker" ];
        environment = authentikEnv;
        environmentFiles = [ config.age.secrets."authentik/authentik.env".path ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "/var/lib/authentik/media:/media"
          "/var/lib/authentik/certs:/certs"
          "/var/lib/authentik/templates:/templates"
        ];
        dependsOn = [ "authentik-redis" ];
        extraOptions = [
          "--dns=192.168.1.1"
          "--network=authentik"
        ];
      };
    };

  services.nginx.upstreams.authentik = {
    servers."127.0.0.1:${toString config.shiro.ports.authentik-ssl}" = { };
    extraConfig = ''
      keepalive 10;
    '';
  };

  modules.services.nginx.virtualHosts."sso.shiro.lan" = {
    ssl = true;
    locations."/" = {
      proxyWebsockets = true;
      proxyPass = "https://authentik";
      extraConfig = ''
        set $my_host $http_host;
        if ($http_x_override_host) {
          set $my_host $http_x_override_host;
        }

        add_header              X-Host $my_host always;
        proxy_set_header        Host $my_host;
        proxy_set_header        X-Real-IP $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto $scheme;
        proxy_set_header        X-Forwarded-Host $my_host;
        proxy_set_header        X-Forwarded-Server $my_host;
      '';
    };
  };
}
