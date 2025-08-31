{ ... }:
{
  age.secrets = {
    "backup.env".file = ../../secrets/backup/restic-b2.env.age;
    "backup.key".file = ../../secrets/backup/restic-shiro-pass.age;
    "minio.env".file = ../../secrets/shiro/minio.env.age;
    "danbooru.env".file = ../../secrets/shiro/danbooru.env.age;

    containers_vpn-gateway_mullvad-privkey = {
      file = ../../secrets/shiro/vpn-gateway/mullvad_private_key.age;
      path = "/run/container-secrets/vpn-gateway/mullvad-privkey";
      # We can't symlink as the container won't be able to follow it.
      symlink = false;
    };
  };
}
