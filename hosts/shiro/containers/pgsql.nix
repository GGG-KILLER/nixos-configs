{ config, lib, ... }@args:

with lib;
let
  inherit (import ./funcs.nix args) mkContainer;
  mkPgsql = { env, ip }: {
    my.networking."pgsql-${env}" = {
      ipAddrs = {
        elan = ip;
      };
      ports = [
        {
          protocol = "tcp";
          port = 5432;
          description = "PostgreSQL Port";
        }
      ];
    };

    containers."pgsql-${env}" = mkContainer {
      name = "pgsql-${env}";

      includeAnimu = false;
      includeEtc = false;
      includeH = false;

      bindMounts = {
        "/mnt/pgsql" = {
          hostPath = "/zfs-main-pool/data/dbs/pgsql-${env}";
          isReadOnly = false;
        };
      };

      config = { pkgs, ... }:
        let
          pgsql = pkgs.postgresql_14;
        in
        {
          services.postgresql = {
            enable = true;
            package = pgsql;
            dataDir = "/mnt/pgsql";
            enableTCPIP = true;
            settings = {
              # Resource Consumtion Settings (https://www.postgresql.org/docs/14/runtime-config-resource.html)
              shared_buffers = "512MB";       # default: 128M
              work_mem = "16MB";              # default: 4MB
              maintenance_work_mem = "256MB"; # default: 64MB
              max_stack_depth = "7MB";        # default: 2MB
              temp_file_limit = "64GB";       # default: -1 (no limit)

              # WAL Settings (https://www.postgresql.org/docs/14/runtime-config-wal.html)
              wal_compression = true;         # default: false
              wal_init_zero = false;          # default: true
              wal_recycle = false;            # default: true

              # Log Settings (https://www.postgresql.org/docs/14/runtime-config-logging.html)
              log_connections = true;         # default: false
              log_duration = true;            # default: false
              log_line_prefix = "%m [%p] %q[%a@%r] [%u@%d] "; # default: "%m [%p] "
              log_lock_waits = true;          # default: false

              # Statistics Settings (https://www.postgresql.org/docs/14/runtime-config-statistics.html)
              track_activities = true;        # default: true
              track_activity_query_size = "4KB"; # default: 1024
              track_counts = true;            # default: true
              track_io_timing = true;         # default: false
              track_functions = true;         # default: false

              # Client Configurations (https://www.postgresql.org/docs/14/runtime-config-client.html)
              DateStyle = "ISO, YMD";         # default: "ISO, MDY"
              TimeZone = "America/Sao_Paulo"; # default: "GMT"
            };
            extraPlugins = with pgsql.pkgs; [
              smlar
              pgtap
              pg_topn
              periods
              cstore_fdw
              pg_rational
              pg_safeupdate
            ];
          };
        };
    };
  };
in
mkMerge [
  (mkPgsql { env = "dev"; ip = "192.168.1.15"; })
  (mkPgsql { env = "prd"; ip = "192.168.1.16"; })
]
