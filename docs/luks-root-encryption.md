# LUKS root encryption (with initrd-SSH remote unlock)

Describes the pattern used to add full-disk LUKS encryption to a host's root
filesystem, including remote unlock over SSH during boot (before the OS
proper starts). Applied so far to `steph` and `jibril`. Use this doc as a
recipe to apply the same setup to another host.

## Overview

- Root btrfs is wrapped in a LUKS2 container via [disko](https://github.com/nix-community/disko).
  Unlock is passphrase-only (no keyfile).
- Unlock can happen two ways:
  - **Physical console**: the normal boot-time passphrase prompt.
  - **Remote via SSH into the initrd**: `boot.initrd.network` starts an SSH
    server inside the initrd (before root is mounted); connecting and
    running `systemctl default` triggers the same passphrase prompt over
    the SSH session.
- No swap is involved in either host's config.

## disko: wrapping root in LUKS

In `hosts/<host>/disk-config.nix`, the partition that used to have
`content.type = "btrfs"` directly instead gets a `type = "luks"` node in
between:

```nix
root = {
  size = "100%";
  content = {
    type = "luks";
    name = "crypted-root";
    settings = {
      allowDiscards = true;
      bypassWorkqueues = true;
    };
    content = {
      type = "btrfs";
      extraArgs = [ "-f" ];
      mountpoint = "/partition-root";
      subvolumes = { /* unchanged from the pre-encryption config */ };
    };
  };
};
```

This is enough — disko auto-generates `boot.initrd.luks.devices."crypted-root"`
and points `fileSystems` at `/dev/mapper/crypted-root`. **Do not** also
hand-write `boot.initrd.luks.devices` — that double-declares it.

`allowDiscards = true` only matters for SSDs (leaks some info about free
space to the device, standard tradeoff for SSD performance). `bypassWorkqueues
= true` is a dm-crypt performance option, unrelated to security.

See `hosts/steph/disk-config.nix` and `hosts/jibril/disk-config.nix` for two
worked examples (steph additionally has a swapfile subvolume and
`discard=async`/`ssd` mount options; jibril does not — mount options and
subvolume layout are independent of the LUKS wrapping and should be carried
over unchanged from the pre-encryption config).

## initrd-SSH remote unlock

Create `hosts/<host>/system/luks.nix` (or equivalent):

```nix
{ config, ... }:
{
  boot.initrd.availableKernelModules = [ "<nic-driver>" ]; # e.g. "e1000e"

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 22;
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      # `command=` forces SSH to run this instead of a login shell, so we
      # don't need root's shell binary to exist inside the initrd image.
      authorizedKeys = map (
        key: ''command="systemctl default" ${key}''
      ) config.users.users.ggg.openssh.authorizedKeys.keys;
    };
  };

  # Only needed if the host uses static addressing (DHCP off). Omit this
  # block entirely if the host uses DHCP — the initrd will just get an
  # address normally.
  # ip=client::gw:netmask:host:iface:autoconf
  boot.kernelParams = [
    "ip=${config.home.addrs.<host>}::${config.home.addrs.router}:255.255.0.0::<iface>:none"
  ];
}
```

Import it from `hosts/<host>/system/default.nix` (or wherever the host's
module list lives).

Key points, and why they matter:

- **`boot.initrd.availableKernelModules` must include the NIC driver.** The
  initrd is minimal and won't have network without it. Find the right driver
  via `lspci -k` or `nix eval .#nixosConfigurations.<host>.config.boot.initrd.availableKernelModules`
  on a similar host, or by checking what driver the interface uses in the
  fully-booted system (`ethtool -i <iface>`).
- **Use the `command="..."` authorized_keys restriction, not
  `boot.initrd.systemd.users.root.shell`.** This repo uses the default
  systemd-based initrd (`boot.initrd.systemd.enable`, on by default). Under
  systemd-stage-1, setting a custom root shell via
  `boot.initrd.systemd.users.root.shell` does **not** work out of the box:
  that option points at a store path (e.g. a `pkgs.writeShellScript`), but
  systemd-stage-1 only copies store paths into the initrd image that are
  explicitly listed in `boot.initrd.systemd.storePaths` — referencing a
  derivation via string interpolation in an option value does *not*
  automatically add it, unlike a normal system closure. The symptom was
  `sshd-session: User root not allowed because shell ... does not exist`
  in `journalctl -b 0` after a successful boot. The `command=` trick avoids
  the whole problem: SSH runs `systemctl default` directly instead of
  spawning any shell, so no custom shell binary needs to exist in the
  initrd at all. This matches the approach in the
  [NixOS wiki's Remote Disk Unlocking article](https://wiki.nixos.org/wiki/Remote_disk_unlocking).
- **A dedicated throwaway SSH host key is required**, generated directly on
  the target host (not committed to the repo, not an agenix secret — see
  below for why):
  ```
  sudo mkdir -p /etc/secrets/initrd
  sudo ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
  ```
  This key's contents get baked into the initrd image, which lives
  unencrypted on the ESP (`/boot`). Anyone with physical/read access to the
  ESP (or the resulting `/nix/store` initrd derivation) can read it. Because
  of that it must be a throwaway key used *only* for initrd unlock — never
  the host's main SSH host key — and it is intentionally kept out of agenix
  (agenix secrets are decrypted into the *running* system, not into the
  initrd; and there's no point encrypting a secret that ends up plaintext
  in the initrd anyway).
- **`authorizedKeys`** reuses the normal user's already-trusted public keys
  (`config.users.users.<user>.openssh.authorizedKeys.keys`) — no new keypair
  needed on the client side.
- **Static IP setups need `ip=` kernel params** since the initrd doesn't run
  the full NixOS networking stack (no `config.home.addrs.<host>` resolution
  happens automatically there — it's just a kernel cmdline flag). DHCP hosts
  can skip this entirely.

## Deploying the migration itself (existing host, in-place, no spare drive)

This is the risky part and was done with the host live, over SSH, with no
spare drive and without wiping/restoring the existing data. High-level shape
(see `hosts/jibril/system/` git history and the retired plan document for
the full blow-by-blow):

1. **Back up first.** Confirm the host's regular off-site backup ran
   successfully immediately before starting. For databases, take one fresh
   logical dump (e.g. `pg_dumpall`) in addition to filesystem-level backups,
   and copy it off-machine.
2. Make the disko + `luks.nix` config changes (Phase A above) and **build
   only** (`nix build .#nixosConfigurations.<host>.config.system.build.toplevel`).
   **Never activate this build against the still-unencrypted disk** — the
   next boot's initrd would hang forever waiting for a LUKS device that
   doesn't exist yet.
3. Copy the built closure to the target host's Nix store ahead of time
   (`nix copy --to ssh-ng://root@<host>.lan <path>`) and gcroot it there
   (`nix-store --realise <path> --add-root /root/<host>-luks-system`), so
   it survives independent of the network/flake once you're in a rescue
   environment.
4. Boot the target into a rescue/kexec environment that frees up the root
   device (root can't be reencrypted while mounted — including `/nix`,
   which is where `cryptsetup` itself lives). A kexec-based installer that
   keeps network access working is much less painful than a physical USB.
5. From the rescue: shrink the btrfs filesystem to free space at the tail,
   `cryptsetup reencrypt --encrypt --reduce-device-size 32M --type luks2 <partition>`
   to encrypt in place (preserves all data — this is not a wipe),
   then open + grow the filesystem back to fill the container.
6. `nixos-enter` into the mounted, now-encrypted target and activate the
   gcroot-pinned closure from step 3 (`switch-to-configuration boot`, with
   `NIXOS_INSTALL_BOOTLOADER=1` set — plain `switch-to-configuration boot`
   activates the system but does **not** reinstall/update the bootloader by
   itself; you also need `nix-env -p /nix/var/nix/profiles/system --set <path>`
   first so the bootloader-entry generator knows about the new generation).
7. **Back up the LUKS header off-machine** before rebooting
   (`cryptsetup luksHeaderBackup`) — header loss means total data loss, with
   no recovery possible even with the correct passphrase.
8. Reboot. Unlock via console passphrase or, once initrd-SSH is confirmed
   working, `ssh -p 22 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@<host>` and
   enter the passphrase when prompted (the `command="systemctl default"`
   trick drops you straight into the unlock flow).

Have a physical USB installer on hand as a fallback in case the rescue
environment's network doesn't come back, or the reboot doesn't come up.

## Verifying the setup

```bash
# Confirm disko generated the LUKS device wiring correctly
nix eval .#nixosConfigurations.<host>.config.boot.initrd.luks.devices --json

# Confirm the initrd will have network + the right NIC driver
nix eval .#nixosConfigurations.<host>.config.boot.initrd.availableKernelModules --json

# Confirm the authorized_keys line has the command= restriction baked in
nix eval --json .#nixosConfigurations.<host>.config.boot.initrd.network.ssh.authorizedKeys
```

To test remote unlock against a booted (locked) host:

```bash
ssh -p 22 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@<host>.lan
```

The host-key check must be skipped since the initrd uses the throwaway key
generated in the setup step, which isn't (and shouldn't be) recorded in
`~/.ssh/known_hosts`.
