{ ... }:

{
  age.secrets = {
    backup-password.file = ../../secrets/sora/backup_password;

    step-ca-intermediate-crt.file = ../../secrets/stepca/intermediate_ca.crt;
    step-ca-root-crt.file = ../../secrets/stepca/root_ca.crt;
  };
}
