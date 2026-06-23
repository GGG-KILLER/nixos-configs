{ ... }:
{
  age.secrets = {
    "authentik/authentik.env".file = ../../secrets/jibril/authentik/authentik.env.age;
    "cloudflared/3c1b8ea8-a43d-4a97-872c-37752de30b3f.json".file =
      ../../secrets/home/cloudflared/3c1b8ea8-a43d-4a97-872c-37752de30b3f.json.age;
    "glorp.env".file = ../../secrets/jibril/glorp.env.age;
    "netprobesharp.env".file = ../../secrets/jibril/netprobesharp.env.age;

    "backup.env".file = ../../secrets/backup/restic-b2.env.age;
    "backup.key".file = ../../secrets/backup/restic-jibril-pass.age;

    n8n-encryption-key.file = ../../secrets/jibril/n8n/encryption_key.age;
    n8n-pgsql-password.file = ../../secrets/jibril/n8n/pgsql/password.age;

    grafana_secret_key = {
      file = ../../secrets/jibril/grafana/secret_key.age;
      owner = "grafana";
    };

    pgadmin-pass = {
      file = ../../secrets/jibril/pgsql/prd_pass.age;
      owner = "996";
    };
  };
}
