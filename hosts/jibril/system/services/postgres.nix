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

  #       export NEWDATA="/var/lib/pgsql-prd/${newPostgres.psqlSchema}"

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

  # TODO: Uncomment once NixOS/nixpkgs#461494 hits unstable
  # services.pgadmin = {
  #   enable = true;
  #   initialEmail = "gggkiller2@gmail.com";
  #   initialPasswordFile = config.age.secrets.pgadmin-pass.path;
  # };

  services.postgresql = {
    enable = true;
    package = pgsql;
    dataDir = "/var/lib/pgsql-prd/${pgsql.psqlSchema}";
    enableJIT = true;
    enableTCPIP = true;
    authentication = mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             0.0.0.0/0               scram-sha-256
      host    all             all             ::0/0                   scram-sha-256
    '';
    settings = {
      port = config.jibril.ports.postgres;

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

  modules.services.nginx.virtualHosts."postgres.lan" = {
    ssl = true;
    locations."/" = {
      extraConfig = ''
        proxy_pass http://127.0.0.1:${toString config.services.pgadmin.port};
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ config.jibril.ports.postgres ];
}
