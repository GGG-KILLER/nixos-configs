{
  config,
  lib,
  ...
} @ args:
with lib; let
  inherit (import ./funcs.nix args) mkContainer;
  mkPgsql = {
    env,
    ip,
  }: {
    my.networking."pgsql-${env}" = {
      ipAddr = ip;
      ports = [
        {
          protocol = "http";
          port = 80;
          description = "Nginx";
        }
        {
          protocol = "http";
          port = 443;
          description = "Local Nginx";
        }
        {
          protocol = "tcp";
          port = 5432;
          description = "PostgreSQL Port";
        }
      ];
    };

    containers."pgsql-${env}" = mkContainer {
      name = "pgsql-${env}";
      ephemeral = false;

      includeAnimu = false;
      includeSeries = false;
      includeEtc = false;
      includeH = false;

      bindMounts = {
        "/mnt/pgsql" = {
          hostPath = "/zfs-main-pool/data/dbs/pgsql-${env}";
          isReadOnly = false;
        };
        "/secrets" = {
          hostPath = "/run/container-secrets/pgsql-${env}";
          isReadOnly = true;
        };
      };

      config = {
        lib,
        pkgs,
        config,
        ...
      }:
        with lib; let
          pgsql = pkgs.postgresql_14;
        in {
          i18n.supportedLocales = [
            "en_US.UTF-8/UTF-8"
            "pt_BR.UTF-8/UTF-8"
          ];

          # TODO: Uncomment when this gets merged: https://github.com/NixOS/nixpkgs/pull/188575
          # services.pgadmin = {
          #   enable = true;
          #   initialEmail = "gggkiller2@gmail.com";
          #   initialPasswordFile = "/secrets/pgadmin-pass";
          # };
          # systemd.tmpfiles.rules = [
          #   "d '/var/lib/pgadmin' 0755 pgadmin pgadmin"
          #   "d '/var/log/pgadmin' 0755 pgadmin pgadmin"
          # ];

          services.postgresql = {
            enable = true;
            package = pgsql;
            dataDir = "/mnt/pgsql";
            enableTCPIP = true;
            authentication = mkForce ''
              # TYPE  DATABASE        USER            ADDRESS                 METHOD
              local   all             all                                     trust
              host    all             all             127.0.0.1/32            scram-sha-256
              host    all             all             ::1/128                 scram-sha-256
              host    all             all             192.168.1.0/24          scram-sha-256
            '';
            settings = {
              # Resource Consumtion Settings (https://www.postgresql.org/docs/14/runtime-config-resource.html)
              shared_buffers = "512MB"; #       default: 128M
              work_mem = "16MB"; #              default: 4MB
              maintenance_work_mem = "256MB"; # default: 64MB
              max_stack_depth = "7MB"; #        default: 2MB
              temp_file_limit = "64GB"; #       default: -1 (no limit)

              # WAL Settings (https://www.postgresql.org/docs/14/runtime-config-wal.html)
              wal_compression = true; #         default: false
              wal_init_zero = false; #          default: true
              wal_recycle = false; #            default: true

              # Log Settings (https://www.postgresql.org/docs/14/runtime-config-logging.html)
              log_connections = true; #         default: false
              log_duration = true; #            default: false
              log_line_prefix = mkForce "%m [%p] %q[%a@%r] [%u@%d] "; # default: "%m [%p] "
              log_lock_waits = true; #          default: false

              # Statistics Settings (https://www.postgresql.org/docs/14/runtime-config-statistics.html)
              track_activities = true; #        default: true
              track_activity_query_size = "4kB"; # default: 1024
              track_counts = true; #            default: true
              track_io_timing = true; #         default: false
              track_functions = "all"; #        default: none

              # Client Configurations (https://www.postgresql.org/docs/14/runtime-config-client.html)
              DateStyle = "ISO, YMD"; #         default: "ISO, MDY"
              TimeZone = "America/Sao_Paulo"; # default: "GMT"
            };
            extraPlugins = with pgsql.pkgs; [
              smlar
              pgtap
              pg_topn
              periods
              # cstore_fdw (Requires PostgreSQL < 12)
              pg_rational
              # pg_safeupdate
            ];
          };

          security.acme.certs."pg${env}.shiro.lan".email = "pg${env}@pg${env}.lan";
          services.nginx = {
            enable = true;
            virtualHosts."pg${env}.shiro.lan" = {
              enableACME = true;
              addSSL = true;
              locations."/" = {
                extraConfig = ''
                  proxy_pass http://localhost:${toString config.services.pgadmin.port};
                  proxy_http_version 1.1;
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header Connection "upgrade";
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  proxy_set_header X-Forwarded-Protocol $scheme;
                  proxy_set_header X-Forwarded-Host $http_host;
                  proxy_read_timeout 6h;
                '';
              };
            };
          };
        };
    };
  };
in {
  config = mkMerge [
    (mkPgsql {
      env = "dev";
      ip = "192.168.1.15";
    })
    (mkPgsql {
      env = "prd";
      ip = "192.168.1.16";
    })
  ];
}
