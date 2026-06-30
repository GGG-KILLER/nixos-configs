{ config, ... }:
{
  jibril.dynamic-ports = [ "uptime-kuma" ];

  services.uptime-kuma.enable = true;
  services.uptime-kuma.settings = {
    NODE_EXTRA_CA_CERTS = config.security.pki.caBundle;
    PORT = toString config.jibril.ports.uptime-kuma;
  };

  # Allow reaching docker socket.
  systemd.services.uptime-kuma.serviceConfig.SupplementaryGroups = [ "docker" ];

  # Read-only liveness-check role for the postgres monitor: no SUPERUSER/CREATEDB/
  # CREATEROLE/REPLICATION and no table/schema grants, so it can do nothing but
  # connect. The clause is a pre-computed SCRAM-SHA-256 hash (not the plaintext
  # password), which Postgres stores verbatim instead of re-hashing.
  # Connection string: postgres://uptime_kuma:GSEwEG224sYjRf2abGWmL153lnGRZSI@127.0.0.1:5432/postgres
  services.postgresql.ensureUsers = [
    {
      name = "uptime_kuma";
      ensureClauses.password = "SCRAM-SHA-256$4096:6E0is4u8t7tONiWDspFZYg==$zG7LBEtOXkmcgJAeEmiUwEmUgK9hazoj9o8eGpHtRmM=:axAnYNFjeCNsSjrznng5DFL4HjyI2flYpyjJkDimJIo=";
    }
  ];

  services.caddy.virtualHosts."status.jibril.lan".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString config.jibril.ports.uptime-kuma}
  '';
}
