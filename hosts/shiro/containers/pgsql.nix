{ lib, ... }:
let
  mkPgsql =
    { env, ip }:
    {
      my.networking."pgsql-${env}" = {
        mainAddr = ip;
        extraNames = [ "pg${env}.shiro" ];
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

      modules.containers."pgsql-${env}" = {
        timeoutStartSec = "2min";

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

        extraFlags = [
          "--property=MemoryMax=${(if env == "prd" then "2G" else "1G")}"
        ];

        config =
          {
            lib,
            pkgs,
            config,
            ...
          }:
          with lib;
          let
            pgsql = pkgs.postgresql_17;
          in
          {
            i18n.supportedLocales = [
              "en_US.UTF-8/UTF-8"
              "pt_BR.UTF-8/UTF-8"
            ];

            # NOTE: Use when upgrading between major versions.
            # environment.systemPackages = [
            #   (
            #     let
            #       # XXX specify the postgresql package you'd like to upgrade to.
            #       # Do not forget to list the extensions you need.
            #       newPostgres = pkgs.postgresql_17.withJIT.withPackages (pp: [
            #         # smlar (broken)
            #         pp.pgtap
            #         pp.pg_topn
            #         pp.periods
            #         pp.pg_rational
            #       ]);
            #       cfg = config.services.postgresql;
            #     in
            #     pkgs.writeScriptBin "upgrade-pg-cluster" ''
            #       set -eux
            #       # XXX it's perhaps advisable to stop all services that depend on postgresql
            #       systemctl stop postgresql

            #       export NEWDATA="/mnt/pgsql/${newPostgres.psqlSchema}"

            #       export NEWBIN="${newPostgres}/bin"

            #       export OLDDATA="${cfg.dataDir}"
            #       export OLDBIN="${
            #         cfg.package.withJIT.withPackages (pp: [
            #           # smlar (broken)
            #           pp.pgtap
            #           pp.pg_topn
            #           pp.periods
            #           pp.pg_rational
            #         ])
            #       }/bin"

            #       install -d -m 0700 -o postgres -g postgres "$NEWDATA"
            #       cd "$NEWDATA"
            #       sudo -u postgres $NEWBIN/initdb -D "$NEWDATA" ${lib.escapeShellArgs cfg.initdbArgs}

            #       sudo -u postgres $NEWBIN/pg_upgrade \
            #         --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
            #         --old-bindir $OLDBIN --new-bindir $NEWBIN \
            #         "$@"
            #     ''
            #   )
            # ];

            services.pgadmin = {
              enable = true;
              initialEmail = "gggkiller2@gmail.com";
              initialPasswordFile = "/secrets/pgadmin-pass";
              settings = {
                DATA_DIR = "/mnt/pgsql/pgadmin4/";
              };
            };
            systemd.services.pgadmin.serviceConfig = {
              ReadWritePaths = [ "/mnt/pgsql/pgadmin4/" ];
              Restart = "always";
              RestartSec = "5s";
            };

            services.postgresql = {
              enable = true;
              package = pgsql;
              dataDir = "/mnt/pgsql/${pgsql.psqlSchema}";
              enableJIT = true;
              enableTCPIP = true;
              authentication = mkForce ''
                # TYPE  DATABASE        USER            ADDRESS                 METHOD
                local   all             all                                     trust
                host    all             all             127.0.0.1/32            scram-sha-256
                host    all             all             ::1/128                 scram-sha-256
                host    all             all             192.168.0.0/16          scram-sha-256
              '';
              settings = {
                # Resource Consumtion Settings (https://www.postgresql.org/docs/14/runtime-config-resource.html)
                shared_buffers = "512MB"; # default: 128M
                work_mem = "16MB"; # default: 4MB
                maintenance_work_mem = "256MB"; # default: 64MB
                max_stack_depth = "7MB"; # default: 2MB
                temp_file_limit = "64GB"; # default: -1 (no limit)

                # WAL Settings (https://www.postgresql.org/docs/14/runtime-config-wal.html)
                wal_compression = true; # default: false
                wal_init_zero = false; # default: true
                wal_recycle = false; # default: true

                # Log Settings (https://www.postgresql.org/docs/14/runtime-config-logging.html)
                log_connections = true; # default: false
                log_duration = true; # default: false
                log_line_prefix = mkForce "%m [%p] %q[%a@%r] [%u@%d] "; # default: "%m [%p] "
                log_lock_waits = true; # default: false

                # Statistics Settings (https://www.postgresql.org/docs/14/runtime-config-statistics.html)
                track_activities = true; # default: true
                track_activity_query_size = "4kB"; # default: 1024
                track_counts = true; # default: true
                track_io_timing = true; # default: false
                track_functions = "all"; # default: none

                # Client Configurations (https://www.postgresql.org/docs/14/runtime-config-client.html)
                DateStyle = "ISO, YMD"; # default: "ISO, MDY"
                TimeZone = "America/Sao_Paulo"; # default: "GMT"
              };
              extensions = with pgsql.pkgs; [
                # smlar (broken)
                pgtap
                pg_topn
                periods
                pg_rational
              ];
            };

            security.acme.certs."pg${env}.shiro.lan".email = "pg${env}@pg${env}.lan";
            services.nginx = {
              enable = true;

              proxyTimeout = "12h";
              recommendedProxySettings = true;
              recommendedOptimisation = true;
              recommendedBrotliSettings = true;
              recommendedGzipSettings = true;
              recommendedZstdSettings = true;

              virtualHosts."pg${env}.shiro.lan" = {
                enableACME = true;
                addSSL = true;
                locations."/" = {
                  extraConfig = ''
                    proxy_pass http://127.0.0.1:${toString config.services.pgadmin.port};
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection "upgrade";
                  '';
                };
              };
            };
          };
      };
    };
in
{
  config = lib.mkMerge [
    # (mkPgsql {
    #   env = "dev";
    #   ip = "192.168.2.19"; # ipgen -n 192.168.2.0/24 pgsql-dev
    # })
    (mkPgsql {
      env = "prd";
      ip = "192.168.2.241"; # ipgen -n 192.168.2.0/24 pgsql-prd
    })
  ];
}
