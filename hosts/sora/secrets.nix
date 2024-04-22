{...}: {
  age.secrets = {
    backup-password.file = ../../secrets/sora/backup_password.age;
    backup-envfile.file = ../../secrets/sora/backup_envfile.age;

    shiro-backup-password.file = ../../secrets/shiro/backup_password.age;
    shiro-backup-envfile.file = ../../secrets/shiro/backup_envfile.age;

    "foldingathome.xml" = {
      file = ../../secrets/foldingathome.xml.age;
      mode = "444"; # Yes, not exactly a secret. But the service uses DynamicUser.
    };
  };
}
