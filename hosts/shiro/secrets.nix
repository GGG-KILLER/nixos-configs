{ ... }:
{
  age.secrets = {
    backup-password.file = ../../secrets/home/backup_password.age;
    backup-envfile.file = ../../secrets/home/backup_envfile.age;
    "minio.env".file = ../../secrets/shiro/minio.env.age;
    "danbooru.env".file = ../../secrets/shiro/danbooru.env.age;

    "cloudflared/3c1b8ea8-a43d-4a97-872c-37752de30b3f.json".file =
      ../../secrets/home/cloudflared/3c1b8ea8-a43d-4a97-872c-37752de30b3f.json.age;

    containers_vpn-gateway_mullvad-privkey = {
      file = ../../secrets/shiro/vpn-gateway/mullvad_private_key.age;
      path = "/run/container-secrets/vpn-gateway/mullvad-privkey";
      # We can't symlink as the container won't be able to follow it.
      symlink = false;
    };
  };
}
