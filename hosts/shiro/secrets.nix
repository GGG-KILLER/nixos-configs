{...}: {
  age.secrets = {
    backup-password.file = ../../secrets/shiro/backup_password.age;
    backup-envfile.file = ../../secrets/shiro/backup_envfile.age;
    "mnn-server.env".file = ../../secrets/shiro/mnn-server.env.age;
    "valheim-server.env".file = ../../secrets/shiro/valheim-server.env.age;

    wireguard-key.file = ../../secrets/shiro/wireguard/private_key.age;
    wireguard-laptop-psk.file = ../../secrets/shiro/wireguard/laptop_psk.age;
    wireguard-phone-psk.file = ../../secrets/shiro/wireguard/phone_psk.age;

    "pterodactyl/db.env".file = ../../secrets/shiro/pterodactyl/db.env.age;
    "pterodactyl/panel.env".file = ../../secrets/shiro/pterodactyl/panel.env.age;

    step-ca-intermediate-key = {
      file = ../../secrets/shiro/stepca/intermediate_ca_key.age;
      owner = "step-ca";
      group = "step-ca";
    };
    step-ca-intermediate-key-password = {
      file = ../../secrets/shiro/stepca/keys_password.age;
      owner = "step-ca";
      group = "step-ca";
    };

    containers_vpn-gateway_mullvad-privkey = {
      file = ../../secrets/shiro/vpn-gateway/mullvad_private_key.age;
      path = "/run/container-secrets/vpn-gateway/mullvad-privkey";
      # We can't symlink as the container won't be able to follow it.
      symlink = false;
    };

    containers_pgsql-dev_pgadmin-pass = {
      file = ../../secrets/shiro/pgsql/dev_pass.age;
      path = "/run/container-secrets/pgsql-dev/pgadmin-pass";
      owner = "996";
      # We can't symlink as the container won't be able to follow it.
      symlink = false;
    };
    containers_pgsql-prd_pgadmin-pass = {
      file = ../../secrets/shiro/pgsql/prd_pass.age;
      path = "/run/container-secrets/pgsql-prd/pgadmin-pass";
      owner = "996";
      # We can't symlink as the container won't be able to follow it.
      symlink = false;
    };
  };
}
