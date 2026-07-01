{ pkgs, config, ... }:
{
  boot.zfs.requestEncryptionCredentials = false; # we'll provide the encryption keys

  systemd.services.zfs-load-vault-keys = {
    description = "Load ZFS encryption keys from Openbao";
    after = [
      "network.target" # Need network to call Openbao
      "network-online.target" # Need network to call Openbao
      "nss-lookup.target" # Need DNS to resolve vault.jibril.lan
      "zfs-import.target" # Can't run before we've imported the pool
    ];
    wants = [
      "network-online.target" # Need network to call Openbao
      "nss-lookup.target" # Need DNS to resolve vault.jibril.lan
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = config.age.secrets."zfs_encryption_vault_creds.env".path;
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "15s";

      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
    };

    unitConfig = {
      StartLimitIntervalSec = 600;
      StartLimitBurst = 10;
    };

    path = [
      pkgs.curl
      pkgs.jq
      pkgs.zfs
    ];
    script = ''
      set -xeuo pipefail

      # Authenticate with Vault
      LOGIN_PAYLOAD=$(jq -nc \
        --arg r "$VAULT_ROLE_ID" \
        --arg s "$VAULT_SECRET_ID" \
        '{role_id:$r, secret_id:$s}')

      VAULT_TOKEN=$(curl -sSf \
        ''${VAULT_CACERT:+--cacert "$VAULT_CACERT"} \
        -X POST "$VAULT_ADDR/v1/auth/approle/login" \
        -d "$LOGIN_PAYLOAD" \
        | jq -r '.auth.client_token')

      if [ -z "$VAULT_TOKEN" ] || [ "$VAULT_TOKEN" = "null" ]; then
        echo "ERROR: Vault authentication failed"
        exit 1
      fi

      revoke_token() {
        curl -sSf \
          ''${VAULT_CACERT:+--cacert "$VAULT_CACERT"} \
          -X POST \
          -H "X-Vault-Token: $VAULT_TOKEN" \
          "$VAULT_ADDR/v1/auth/token/revoke-self" \
          || echo "WARNING: failed to revoke Vault token"
      }
      trap revoke_token EXIT

      # Load keys for imported pools whose key is not yet available
      zfs list -H -o name,keystatus \
        | while IFS=$'\t' read -r dataset status; do
            [[ "$dataset" == */* ]] && continue        # skip child datasets
            [ "$status" != "unavailable" ] && continue # skip already-unlocked pools

            echo "Loading key for pool: $dataset"

            PASSWORD=$(curl -sSf \
              ''${VAULT_CACERT:+--cacert "$VAULT_CACERT"} \
              -H "X-Vault-Token: $VAULT_TOKEN" \
              "$VAULT_ADDR/v1/secrets/data/hosts/${config.networking.hostName}/zfs/$dataset" \
              | jq -r '.data.data.key')

            if [ -z "$PASSWORD" ] || [ "$PASSWORD" = "null" ]; then
              echo "ERROR: no key found in Vault for pool '$dataset' — skipping"
              continue
            fi

            printf '%s' "$PASSWORD" | zfs load-key "$dataset" \
              || echo "WARNING: zfs load-key failed for $dataset"
          done
    '';
  };
}
