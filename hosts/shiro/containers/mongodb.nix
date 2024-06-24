{lib, ...}: let
  mkMongo = {
    env,
    ip,
  }: {
    my.networking."mongo-${env}" = {
      mainAddr = ip;
      extraNames = ["mongo-${env}.shiro"];
      ports = [
        {
          protocol = "tcp";
          port = 27017;
          description = "MongoDB Port";
        }
      ];
    };

    modules.containers."mongo-${env}" = {
      timeoutStartSec = "2min";

      bindMounts = {
        "/var/db/mongodb" = {
          hostPath = "/zfs-main-pool/data/dbs/mongo-${env}";
          isReadOnly = false;
        };
        "/secrets" = {
          hostPath = "/run/container-secrets/mongo-${env}";
          isReadOnly = true;
        };
      };

      config = {
        lib,
        pkgs,
        config,
        ...
      }: {
        nixpkgs.config.allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            "steam-original"
            "steam-run"
            "mongodb"
          ];

        i18n.supportedLocales = [
          "en_US.UTF-8/UTF-8"
          "pt_BR.UTF-8/UTF-8"
        ];

        services.mongodb = {
          enable = true;
          bind_ip = "0.0.0.0";

          enableAuth = true;
          initialRootPassword = "@*%Z#5mszXmL9Lv89$AW^A$$N6ffe@";
        };
      };
    };
  };
in {
  config = lib.mkMerge [
    (mkMongo {
      env = "dev";
      ip = "192.168.2.118"; # ipgen -n 192.168.2.0/24 "mongo-dev (coll)"
    })
    (mkMongo {
      env = "prd";
      ip = "192.168.2.226"; # ipgen -n 192.168.2.0/24 mongo-prd
    })
  ];
}
