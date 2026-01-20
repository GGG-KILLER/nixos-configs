{
  self,
  system,
  lib,
  config,
  ...
}:
let
  inherit (lib) map mkMerge mkIf;

  imagesPath = "/storage/services/danbooru/images";

  defaultContainerFlags = [
    "--dns=${config.home.addrs.router}"
    "--ipc=none"
    "--network=danbooru"
  ];

  danbooruContainerBase = rec {
    imageFile = self.packages.${system}.docker-images."ghcr.io/danbooru/danbooru:master";
    image = imageFile.destNameTag;

    environment = {
      DANBOORU_APP_NAME = "Shirobooru";
      DANBOORU_CANONICAL_APP_NAME = "Shirobooru";
      DANBOORU_CANONICAL_URL = "https://booru.shiro.lan";
      DANBOORU_REVERSE_PROXY = "true";
      DANBOORU_IMAGE_STORAGE_PATH = "/images";
      DANBOORU_IQDB_URL = "http://iqdb:5588";
      DANBOORU_REDIS_URL = "redis://redis:6379";
      DANBOORU_AUTOTAGGER_URL = "http://autotagger:5000";

      RAILS_ENV = "production";
      RAILS_LOG_LEVEL = "info";
    };
    environmentFiles = [ config.age.secrets."danbooru.env".path ];

    volumes = [
      "${./danbooru_local_config.rb}:/danbooru/config/danbooru_local_config.rb:ro"
      "${imagesPath}:/images"
    ];

    extraOptions = defaultContainerFlags ++ [
      # Make FS readonly
      "--read-only"

      # Healthchecks
      "--health-cmd='curl -f http://localhost:3000/up'"
      "--health-start-period=120s"
      "--health-interval=10s"
      "--health-retries=1"

      # Make temp dir tmpfs
      "--tmpfs=/tmp"
    ];
  };
in
{
  config = mkIf (!config.cost-saving.enable || !config.cost-saving.disable-downloaders) {
    systemd.services."${config.virtualisation.oci-containers.backend}-danbooru-network" =
      let
        backend = config.virtualisation.oci-containers.backend;
        containers = [
          "danbooru-danbooru"
          "danbooru-cron"
          "danbooru-jobs"
          "danbooru-iqdb"
          "danbooru-redis"
          "danbooru-nginx"
          "danbooru-autotagger"
        ];
      in
      {
        wantedBy = [ "multi-user.target" ];
        after = [
          "docker.service"
          "docker.socket"
        ];
        before = map (name: "${backend}-${name}.service") containers;
        requiredBy = map (name: "${backend}-${name}.service") containers;

        serviceConfig =
          let
            backendBin = "${config.virtualisation.${backend}.package}/bin/${backend}";
          in
          {
            Type = "simple";
            RemainAfterExit = "yes";

            ExecStartPre = "-${backendBin} network rm danbooru";
            ExecStart = "${backendBin} network create danbooru";
            ExecStop = "${backendBin} network rm danbooru";
          };
      };

    virtualisation.oci-containers.containers.danbooru-danbooru = mkMerge [
      danbooruContainerBase
      {
        cmd = [
          "bash"
          "-c"
          "bin/rails db:prepare && bin/rails server -b 0.0.0.0"
        ];

        extraOptions = [
          "--network-alias=danbooru"
        ];
      }
    ];

    virtualisation.oci-containers.containers.danbooru-cron = mkMerge [
      danbooruContainerBase
      {
        cmd = [
          "bin/rails"
          "danbooru:cron"
        ];
        dependsOn = [ "danbooru-danbooru" ];

        extraOptions = [
          "--network-alias=cron"
        ];
      }
    ];

    virtualisation.oci-containers.containers.danbooru-jobs = mkMerge [
      danbooruContainerBase
      {
        cmd = [
          "bin/good_job"
          "start"
        ];
        dependsOn = [ "danbooru-danbooru" ];

        extraOptions = [
          "--network-alias=jobs"
        ];
      }
    ];

    # https://github.com/danbooru/iqdb
    # https://hub.docker.com/repository/docker/evazion/iqdb
    virtualisation.oci-containers.containers.danbooru-iqdb = rec {
      imageFile = self.packages.${system}.docker-images."evazion/iqdb:latest";
      image = imageFile.destNameTag;

      cmd = [
        "http"
        "0.0.0.0"
        "5588"
        "/iqdb/data/iqdb.sqlite"
      ];

      volumes = [
        "/storage/services/danbooru/iqdb:/iqdb/data"
      ];

      extraOptions = defaultContainerFlags ++ [
        "--network-alias=iqdb"
      ];
    };

    virtualisation.oci-containers.containers.danbooru-redis = rec {
      imageFile = self.packages.${system}.docker-images."redis:latest";
      image = imageFile.destNameTag;

      extraOptions = defaultContainerFlags ++ [
        "--network-alias=redis"
      ];
    };

    virtualisation.oci-containers.containers.danbooru-nginx = {
      inherit (danbooruContainerBase) imageFile image;

      cmd = [
        "openresty"
        "-e"
        "/dev/stderr"
      ];
      ports = [ "${toString config.shiro.ports.danbooru}:3000" ];
      dependsOn = [ "danbooru-danbooru" ];

      environment = {
        DANBOORU_PORT = "3000";
        inherit (danbooruContainerBase.environment) DANBOORU_REVERSE_PROXY DANBOORU_CANONICAL_URL;
      };

      volumes = [
        "${./nginx.conf}:/usr/local/nginx/conf/nginx.conf:ro"
        "${imagesPath}:/images"
      ];

      extraOptions = defaultContainerFlags ++ [
        "--network-alias=nginx"
      ];
    };

    virtualisation.oci-containers.containers.danbooru-autotagger = rec {
      imageFile = self.packages.${system}.docker-images."ghcr.io/danbooru/autotagger:latest";
      image = imageFile.destNameTag;

      extraOptions = defaultContainerFlags ++ [
        "--network-alias=autotagger"
      ];
    };

    # This is only for the nginx config of the danbooru.
    modules.services.nginx.virtualHosts."booru.shiro.lan" = {
      ssl = true;
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:${toString config.shiro.ports.danbooru}";
        extraConfig = ''
          # Not set by default by recommendedProxySettings
          proxy_set_header X-Forwarded-Port $server_port;
        '';
      };
    };
  };
}
