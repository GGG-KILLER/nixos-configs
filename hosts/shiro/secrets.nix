{ ... }:

{
  age.secrets = {
    backup-password.file = ../../secrets/shiro/backup_password;

    wireguard-key.file = ../../secrets/shiro/wireguard/private_key;
    wireguard-laptop-psk.file = ../../secrets/shiro/wireguard/laptop_psk;
    wireguard-phone-psk.file = ../../secrets/shiro/wireguard/phone_psk;

    step-ca-intermediate-key.file = ../../secrets/stepca/intermediate_ca_key;
    step-ca-intermediate-crt.file = ../../secrets/stepca/intermediate_ca.crt;
    step-ca-root-key.file = ../../secrets/stepca/root_ca_key;
    step-ca-root-crt.file = ../../secrets/stepca/root_ca.crt;
  };
}
