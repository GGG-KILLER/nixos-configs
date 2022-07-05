{ ... }:

{
  age.secrets = {
    backup-password.file = ../../secrets/shiro/backup_password;

    step-ca-intermediate-key.file = ../../secrets/shiro/stepca/intermediate_ca_key;
    step-ca-intermediate-crt.file = ../../secrets/shiro/stepca/intermediate_ca.crt;
    step-ca-root-key.file = ../../secrets/shiro/stepca/root_ca_key;
    step-ca-root-crt.file = ../../secrets/shiro/stepca/root_ca.crt;
  };
}
