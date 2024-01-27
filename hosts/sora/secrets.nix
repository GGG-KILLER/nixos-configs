{...}: {
  age.secrets = {
    backup-password.file = ../../secrets/sora/backup_password.age;
    backup-envfile.file = ../../secrets/sora/backup_envfile.age;

    shiro-backup-password.file = ../../secrets/shiro/backup_password.age;
    shiro-backup-envfile.file = ../../secrets/shiro/backup_envfile.age;

    "ggg-nix.conf" = {
      file = ../../secrets/sora/users/ggg/nix.conf.age;
      mode = "400";
      owner = "ggg";
      group = "users";
    };
  };
}
