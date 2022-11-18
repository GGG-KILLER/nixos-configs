{
  config,
  lib,
  ...
} @ args:
with lib; let
  mkPgsql = {
    env,
    ip,
    hostPort,
  }: {
    modules.containers."pgsql-${env}" = {
      ephemeral = false;
      timeoutStartSec = "3min";

      hostBridge = "br-ctlan";
      localAddress = "${ip}/24";

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

      forwardPorts = [
        # PostgreSQL Port
        {
          protocol = "tcp";
          inherit hostPort;
          containerPort = 5432;
        }
      ];

      config = {
        lib,
        pkgs,
        config,
        ...
      }:
        with lib; let
          pgsql = pkgs.postgresql_14;
        in {
          networking = {
            defaultGateway = "172.16.0.1";
            nameservers = ["192.168.1.1"];
          };

          i18n.supportedLocales = [
            "en_US.UTF-8/UTF-8"
            "pt_BR.UTF-8/UTF-8"
          ];

          services.pgadmin = {
            enable = true;
            initialEmail = "gggkiller2@gmail.com";
            initialPasswordFile = "/secrets/pgadmin-pass";
          };
          systemd.tmpfiles.rules = [
            "d '/var/lib/pgadmin' 0755 pgadmin pgadmin"
            "d '/var/log/pgadmin' 0755 pgadmin pgadmin"
          ];

          services.postgresql = {
            enable = true;
            package = pgsql;
            dataDir = "/mnt/pgsql";
            enableTCPIP = true;
            authentication = mkForce ''
              # TYPE  DATABASE        USER            ADDRESS                 METHOD
              local   all             all                                     trust
              host    all             all             127.0.0.1/32            scram-sha-256
              host    all             all             192.168.1.0/24          scram-sha-256
              host    all             all             172.16.0.0/24             scram-sha-256
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

          networking.firewall.allowedTCPPorts = [5432];

          modules.services.nginx = {
            enable = true;
            virtualHosts."pg${env}.shiro.lan" = {
              ssl = false;
              extraConfig = ''
                set_real_ip_from 172.16.0.0/24;
              '';
              locations."/" = {
                proxyPass = "http://localhost:${toString config.services.pgadmin.port}";
                proxyWebsockets = true;
                extraConfig = ''
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
      ip = "172.16.0.6";
      hostPort = 5432;
    })
    (mkPgsql {
      env = "prd";
      ip = "172.16.0.7";
      hostPort = 5433;
    })
  ];
}
