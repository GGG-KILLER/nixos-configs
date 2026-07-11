{ ... }:
{
  age.secrets = {
    "backup.env".file = ../../secrets/backup/restic-b2.env.age;
    "backup.key".file = ../../secrets/backup/restic-shiro-pass.age;
    "danbooru.env".file = ../../secrets/shiro/danbooru.env.age;
    "mikochi.env".file = ../../secrets/shiro/mikochi.env.age;

    "mullvad-privkey".file = ../../secrets/shiro/vpn-gateway/mullvad_private_key.age;
  };
}
