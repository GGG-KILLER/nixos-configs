{ ... }:
{
  age.secrets = {
    backup-password.file = ../../secrets/shiro/backup_password.age;
    backup-envfile.file = ../../secrets/shiro/backup_envfile.age;
    "minio.env".file = ../../secrets/shiro/minio.env.age;
    "netprobe.env".file = ../../secrets/shiro/netprobe.env.age;
    "danbooru.env".file = ../../secrets/shiro/danbooru.env.age;
    "glorp.env".file = ../../secrets/shiro/glorp.env.age;
    pr-tracker-token.file = ../../secrets/shiro/pr-tracker-token.age;

    wireguard-key.file = ../../secrets/shiro/wireguard/private_key.age;
    wireguard-laptop-psk.file = ../../secrets/shiro/wireguard/laptop_psk.age;
    wireguard-phone-psk.file = ../../secrets/shiro/wireguard/phone_psk.age;
    wireguard-coffee-psk.file = ../../secrets/shiro/wireguard/coffee_psk.age;
    wireguard-coffee2-psk.file = ../../secrets/shiro/wireguard/coffee2_psk.age;
    wireguard-night-psk.file = ../../secrets/shiro/wireguard/night_psk.age;

    "cloudflared/3c1b8ea8-a43d-4a97-872c-37752de30b3f.json".file =
      ../../secrets/shiro/cloudflared/3c1b8ea8-a43d-4a97-872c-37752de30b3f.json.age;

    n8n-encryption-key.file = ../../secrets/shiro/n8n/encryption_key.age;
    n8n-pgsql-password.file = ../../secrets/shiro/n8n/pgsql/password.age;

    step-ca-intermediate-key = {
      file = ../../secrets/shiro/stepca/intermediate_ca_key.age;
      owner = "step-ca";
      group = "step-ca";
    };
    step-ca-intermediate-key-password = {
      file = ../../secrets/shiro/stepca/keys_password.age;
      owner = "step-ca";
      group = "step-ca";
    };

    containers_vpn-gateway_mullvad-privkey = {
      file = ../../secrets/shiro/vpn-gateway/mullvad_private_key.age;
      path = "/run/container-secrets/vpn-gateway/mullvad-privkey";
      # We can't symlink as the container won't be able to follow it.
      symlink = false;
    };

    containers_pgsql-dev_pgadmin-pass = {
      file = ../../secrets/shiro/pgsql/dev_pass.age;
      path = "/run/container-secrets/pgsql-dev/pgadmin-pass";
      owner = "996";
      # We can't symlink as the container won't be able to follow it.
      symlink = false;
    };
    containers_pgsql-prd_pgadmin-pass = {
      file = ../../secrets/shiro/pgsql/prd_pass.age;
      path = "/run/container-secrets/pgsql-prd/pgadmin-pass";
      owner = "996";
      # We can't symlink as the container won't be able to follow it.
      symlink = false;
    };

    "authentik/authentik.env" = {
      file = ../../secrets/shiro/authentik/authentik.env.age;
      path = "/run/container-secrets/sso/authentik.env";
      # We can't symlink as the container won't be able to follow it.
      symlink = false;
    };
  };
}
