{ ... }:

{
  age.secrets = {
    backup-password.file = ../../secrets/shiro/backup_password;

    wireguard-key.file = ../../secrets/shiro/wireguard/private_key;
    wireguard-laptop-psk.file = ../../secrets/shiro/wireguard/laptop_psk;
    wireguard-phone-psk.file = ../../secrets/shiro/wireguard/phone_psk;

    step-ca-intermediate-key.file = ../../secrets/shiro/stepca/intermediate_ca_key;
    step-ca-intermediate-key-password.file = ../../secrets/shiro/stepca/keys_password;
  };
}
