{ ... }:
{
  age.secrets = {
    backup-password.file = ../../secrets/home/backup_password.age;
    backup-envfile.file = ../../secrets/home/backup_envfile.age;
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
