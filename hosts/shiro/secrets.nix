{ ... }:
{
  age.secrets = {
    "dot1x.conf".file = ../../secrets/shiro/dot1x.conf.age;
    "backup.env".file = ../../secrets/backup/restic-b2.env.age;
    "backup.key".file = ../../secrets/backup/restic-shiro-pass.age;
    "danbooru.env".file = ../../secrets/shiro/danbooru.env.age;
    "mikochi.env".file = ../../secrets/shiro/mikochi.env.age;

    "zfs_encryption_vault_creds.env" = {
      file = ../../secrets/shiro/zfs_encryption_vault_creds.env.age;
      owner = "root";
      mode = "0600";
    };

    containers_vpn-gateway_mullvad-privkey = {
      file = ../../secrets/shiro/vpn-gateway/mullvad_private_key.age;
      path = "/run/container-secrets/vpn-gateway/mullvad-privkey";
      # We can't symlink as the container won't be able to follow it.
      symlink = false;
    };
  };
}
