{ ... }:
{
  age.secrets = {
    "authentik/authentik.env".file = ../../secrets/jibril/authentik/authentik.env.age;
    "cloudflared/3c1b8ea8-a43d-4a97-872c-37752de30b3f.json".file =
      ../../secrets/home/cloudflared/3c1b8ea8-a43d-4a97-872c-37752de30b3f.json.age;
    "glorp.env".file = ../../secrets/jibril/glorp.env.age;
    "netprobe.env".file = ../../secrets/jibril/netprobe.env.age;

    "backup.env".file = ../../secrets/backup/restic-b2.env.age;
    "backup.key".file = ../../secrets/backup/restic-jibril-pass.age;

    n8n-encryption-key.file = ../../secrets/jibril/n8n/encryption_key.age;
    n8n-pgsql-password.file = ../../secrets/jibril/n8n/pgsql/password.age;

    grafana_secret_key.file = ../../secrets/jibril/grafana/secret_key.age;

    wireguard-key.file = ../../secrets/jibril/wireguard/private_key.age;
    wireguard-coffee-psk.file = ../../secrets/jibril/wireguard/coffee_psk.age;
    wireguard-coffee2-psk.file = ../../secrets/jibril/wireguard/coffee2_psk.age;
    wireguard-laptop-psk.file = ../../secrets/jibril/wireguard/laptop_psk.age;
    wireguard-night-psk.file = ../../secrets/jibril/wireguard/night_psk.age;
    wireguard-phone-psk.file = ../../secrets/jibril/wireguard/phone_psk.age;

    pgadmin-pass = {
      file = ../../secrets/jibril/pgsql/prd_pass.age;
      owner = "996";
    };
  };
}
