{ pkgs, config, ... }:
{
  # Unlock ZFS `storage`'s encryption key via Clevis, bound to jibril's Tang
  # server, once real networking is up.
  #
  # Deliberately decoupled from zfs-import-storage.service (which imports the
  # pool itself, key or no key, and is required *before* local-fs.target,
  # sysinit.target, and basic.target — i.e. before network is guaranteed to
  # exist). Wiring the unlock into that early unit via nixpkgs' builtin
  # `boot.initrd.clevis` mechanism creates a genuine systemd ordering cycle
  # (network-online.target only comes up *after* basic.target). systemd
  # silently breaks such cycles by dropping an edge, so "wait for network"
  # ends up unenforced and Clevis unlock becomes a race instead of a
  # guarantee. A separate, late, retryable service avoids that entirely — the
  # same shape the previous Openbao-based version of this file used.
  boot.zfs.requestEncryptionCredentials = false; # this service provides the key instead

  systemd.services.zfs-load-clevis-keys = {
    description = "Load ZFS encryption key for \"storage\" via Clevis/Tang";
    after = [
      "network-online.target" # need network to reach jibril's Tang
      "zfs-import.target" # pool must already be imported (unmounted) first
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
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
      pkgs.clevis
      pkgs.jose
      pkgs.curl
      pkgs.bash
      config.boot.zfs.package
    ];
    script = ''
      set -euo pipefail

      if [ "$(zfs get -H -o value keystatus storage)" = "available" ]; then
        echo "Key for storage already loaded"
        exit 0
      fi

      # `network-online.target` being reached doesn't guarantee jibril's Tang
      # is actually answering yet (e.g. its own boot/service startup lagging
      # behind). Retry *inside* this single start attempt rather than relying
      # on the outer Restart=: the storage/* mounts declare
      # x-systemd.requires= on this service, and Requires= is evaluated once
      # against the first start attempt — if that fails, the mount's job
      # fails right then even though this service's own Restart=on-failure
      # later succeeds. So the first attempt has to be the one that works.
      tries=12 # 12 * 5s = up to 60s
      until clevis decrypt < /etc/clevis/storage.jwe | zfs load-key storage; do
        tries=$((tries - 1))
        if [ "$tries" -le 0 ]; then
          echo "ERROR: giving up loading key for storage after retries" >&2
          exit 1
        fi
        echo "Key load failed, retrying in 5s ($tries left)..." >&2
        sleep 5
      done
    '';
  };

  environment.etc."clevis/storage.jwe".source = ./storage.jwe; # committed; only decryptable via jibril's live Tang
}
