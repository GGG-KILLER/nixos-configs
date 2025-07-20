{ ... }:
{
  age.secrets = {
    backup-password.file = ../../secrets/sora/backup_password.age;
    backup-envfile.file = ../../secrets/sora/backup_envfile.age;
    nix-github-token = {
      file = ../../secrets/sora/nix-github-token.age;
      owner = "ggg";
      group = "wheel";
    };

    shiro-backup-password.file = ../../secrets/home/backup_password.age;
    shiro-backup-envfile.file = ../../secrets/home/backup_envfile.age;
  };
}
