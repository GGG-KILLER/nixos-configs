{...}: {
  age.secrets = {
    backup-password.file = ../../secrets/shiro/backup_password;

    wireguard-key.file = ../../secrets/shiro/wireguard/private_key;
    wireguard-laptop-psk.file = ../../secrets/shiro/wireguard/laptop_psk;
    wireguard-phone-psk.file = ../../secrets/shiro/wireguard/phone_psk;

    step-ca-intermediate-key = {
      file = ../../secrets/shiro/stepca/intermediate_ca_key;
      owner = "step-ca";
      group = "step-ca";
    };
    step-ca-intermediate-key-password = {
      file = ../../secrets/shiro/stepca/keys_password;
      owner = "step-ca";
      group = "step-ca";
    };

    containers_vpn-gateway_mullvad-privkey = {
      file = ../../secrets/shiro/vpn-gateway/mullvad_private_key;
      path = "/run/container-secrets/vpn-gateway/mullvad-privkey";
      # We can't symlink as the container won't be able to follow it.
      symlink = false;
    };
  };
}
