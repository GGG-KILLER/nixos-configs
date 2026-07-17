# LUKS root encryption on shiro, auto-unlocked via Clevis + Tang

Describes the plan to add LUKS2 root encryption to `shiro` (the NAS), unlocked
**automatically** at boot via [Clevis](https://github.com/latchset/clevis)
bound to a [Tang](https://github.com/latchset/tang) server hosted on `jibril`
(network-bound disk encryption), instead of a manual passphrase. This is a
companion to [`luks-root-encryption.md`](./luks-root-encryption.md), which
covers the baseline passphrase + initrd-SSH pattern already used on `steph` and
`jibril` — read that doc first. This doc only describes what's *different* for
shiro's Clevis/Tang setup; everything not mentioned here (disko wrapping style
where applicable, the in-place `cryptsetup reencrypt` migration mechanics,
header backup, etc.) follows that doc unchanged.

**Status: Piece 1 (Tang on jibril) is implemented and deployed** (commit
`f6f7aae`, and already proven working end-to-end by shiro's ZFS `storage`
Clevis unlock). Pieces 2 and 3 (shiro's root LUKS config + migration) are not
yet executed.

## Why Clevis + Tang, and why the passphrase stays

Shiro's ZFS pool (`storage`) is already encrypted independently (key loaded
post-boot via Clevis against jibril's Tang, from the committed
`hosts/shiro/storage.jwe` — see `hosts/shiro/disk-encryption.nix`).
Only shiro's **root disk** is unencrypted today (a single btrfs filesystem
declared by UUID in `hosts/shiro/hardware-configuration.nix` — shiro does not
use disko, unlike `jibril`/`steph`).

Shiro is powered on only when needed (not an always-on box), so the goal here
is **not** unattended recovery from a power outage — it's avoiding having to
type or SSH in a passphrase *every single time shiro is turned on*. In the
common case, jibril (the home server) is already up and reachable whenever
shiro is switched on, so Clevis+Tang lets the LUKS container unlock itself
automatically over the LAN with no human involved.

**Worth noting for completeness, though it's not the scenario this is designed
for:** Tang lives on jibril, and jibril's own root is LUKS-encrypted with no
Clevis of its own (passphrase / initrd-SSH only, per the reference doc —
deliberately, to avoid a circular dependency). If jibril happens to be down (or
both machines cold-boot together) when shiro is powered on, shiro's Clevis
unlock attempt fails. The generated Clevis unlock unit in shiro's initrd is a
**one-shot `systemd` service with no retry** (`Type = "oneshot"`, no
`Restart=` — confirmed by reading nixpkgs' `luksroot.nix`): it tries exactly
once at boot and does not keep polling if jibril/Tang come up later during that
same boot attempt. In that case shiro simply falls through to the normal
passphrase prompt, same as before this change — no worse off than today.

**Consequently, Clevis is additive, not a replacement.** The design is —

- The LUKS container keeps its **original passphrase keyslot**.
- Shiro's initrd keeps the **same initrd-SSH remote-unlock** setup from the
  reference doc, as the manual escape hatch for whenever Tang isn't reachable.
- Clevis unlock is a **separate, parallel systemd service** in the initrd (see
  "How it actually unlocks" below) that races the interactive passphrase
  prompt once, at boot. If Tang is unreachable at that moment (jibril down,
  network issue), it simply never succeeds for that boot, and the normal
  passphrase prompt — reachable via console or `./ssh-unlock shiro` — is
  completely unaffected.

Nothing about shiro's ability to boot may ever depend on jibril being up.

## How it actually unlocks (verified against this repo's pinned nixpkgs)

There are two different Clevis integration points in nixpkgs; this plan uses
the JWE-file one (`boot.initrd.clevis`), not the LUKS-header-token one
(`boot.initrd.clevisLuksAskpass` + `clevis luks bind`) — the JWE-file mechanism
is the one that plugs directly into `boot.initrd.luks.devices` and is simpler
to reason about. Verified by reading
`nixos/modules/system/boot/clevis.nix` and `nixos/modules/system/boot/luksroot.nix`
in the pinned nixpkgs (rev `3497aa5c9457a9d88d71fa93a4a8368816fbeeba`, the flake's
current input at time of writing):

- `boot.initrd.clevis.devices.<name>.secretFile` feeds `boot.initrd.secrets`
  (same mechanism as the SSH host key), which exposes it inside the initrd at
  `/etc/clevis/<name>.jwe`. `<name>` must match a key in
  `boot.initrd.luks.devices` — for shiro, `"crypted-root"`.
- **Do not point `secretFile` at a repo source path** (`./root.jwe`).
  Initrd secrets are *not* embedded at build time: `append-initrd-secrets`
  copies them into the initrd **at activation time on the target host**, from
  a path recorded with its string context stripped (deliberately, so secrets
  stay out of the closure). A `./root.jwe` reference therefore resolves to
  the flake checkout's store path on the *build machine*, which doesn't exist
  on the target — remote deploys fail at the bootloader-install step with
  `cp: cannot stat '/nix/store/…-source/hosts/shiro/root.jwe'` (hit this
  during the actual migration). Instead, ship the committed JWE through
  `environment.etc` (which *is* part of the closure) and reference the
  runtime path:
  ```nix
  environment.etc."clevis/root.jwe".source = ./root.jwe;
  boot.initrd.clevis.devices."crypted-root".secretFile = "/etc/clevis/root.jwe";
  ```
  This mirrors how `storage.jwe` is already shipped for the ZFS unlock.
- **The JWE is safe to commit.** Unlike the throwaway SSH host key (whose
  exposure via the world-readable ESP/initrd is the whole reason it's kept out
  of the repo and out of agenix), a Clevis JWE is only decryptable with Tang's
  live cooperation. Baking it into the Nix store — which is exactly as
  world-readable as the ESP — doesn't leak the LUKS passphrase by itself.
  **Do not** apply the SSH-host-key secrecy handling here; commit the JWE at
  `hosts/shiro/root.jwe` (alongside the existing `storage.jwe`).
- When `boot.initrd.luks.devices."crypted-root"` exists and
  `boot.initrd.clevis.devices."crypted-root"` is set, nixpkgs' `luksroot.nix`
  (under `boot.initrd.systemd.enable`, this repo's default) generates a
  **separate systemd service** `cryptsetup-clevis-crypted-root` that decrypts
  the JWE and feeds the result to `cryptsetup` as a keyfile. This runs
  **alongside**, not instead of, the normal interactive/SSH passphrase prompt —
  confirming the fallback design above is structurally sound, not just hoped
  for.
- **Ordering is automatic.** Setting `boot.initrd.clevis.useTang = true` makes
  nixpkgs itself add `wants`/`after = network-online.target` to that generated
  service — no manual systemd ordering needs to be hand-written.

## Piece 1 — Tang server on jibril (done)

Implemented as `hosts/jibril/system/services/tang.nix`, imported from
`hosts/jibril/system/services/default.nix`, following the repo's per-service
pattern (fixed port like `postgres`/`mqtt`, not a Caddy-fronted or dynamic
port):

```nix
{ config, ... }:
{
  services.tang = {
    enable = true;
    listenStream = [ (toString config.jibril.ports.tang) ]; # default/canonical Tang port is 7654
    # Tang enforces its own systemd-level IP allowlist (IPAddressAllow) —
    # this option has NO default and must be set, independent of the nftables
    # firewall rule below.
    ipAddressAllow = [ "10.0.0.0/16" ]; # home LAN, matches the /16 netmask used elsewhere
  };

  networking.firewall.allowedTCPPorts = [ config.jibril.ports.tang ];
}
```

- A fixed `tang = 7654;` entry exists in `hosts/jibril/ports.nix`, alongside the
  existing hard-coded entries (`dns=53`, `http=80`, `https=443`,
  `postgres=5432`, `mqtt=61001`). `7654` is Tang's own conventional default
  port (`services.tang.listenStream` defaults to `["7654"]` in nixpkgs) — reuse
  it rather than picking an arbitrary dynamic-range number, so it's recognizable
  and matches Tang tooling defaults.
- **Two independent access-control layers exist and both need configuring**:
  nftables (`networking.firewall.allowedTCPPorts`, this repo's usual pattern)
  *and* Tang's own `ipAddressAllow` (mandatory, systemd `IPAddressAllow=`/`IPAddressDeny=any`
  under the hood). Don't rely on just one.
- Tang's state (its signing/exchange keys) lives under `StateDirectory = "tang"`
  (i.e. `/var/lib/tang`, `DynamicUser = true`), which is on jibril's own
  encrypted root — **not** on shiro's storage. No mount dependency exists in
  either direction; the only runtime dependency shiro has on jibril is "jibril
  booted and its network + Tang service are up," which is unavoidable and
  exactly the tradeoff this design accepts (with the passphrase/SSH fallback
  covering the case where it isn't).

Reference for the per-service pattern: `hosts/jibril/system/services/postgres.nix`,
`docker-registry.nix` (fixed port + firewall open), `hosts/jibril/ports.nix`.

## Piece 2 — shiro config changes

Root today: btrfs directly on a partition, inner filesystem UUID
`65c29b59-a760-426f-af56-85a6b4c5da13`, declared by hand in
`hardware-configuration.nix` (no disko for shiro). After an in-place
`cryptsetup reencrypt`, the *partition* holds a LUKS2 container; the **inner
btrfs UUID is unchanged**, so the existing `fileSystems.*` entries stay as-is
and resolve automatically once the LUKS mapper device opens. Only the LUKS
device wiring, initrd networking, and Clevis config are new.

New file `hosts/shiro/luks.nix` (shiro's layout is flat — there is no
`system/` subdirectory), imported from `hosts/shiro/configuration.nix`:

```nix
{ config, ... }:
{
  # a) LUKS device — hand-written since shiro doesn't use disko.
  boot.initrd.luks.devices."crypted-root" = {
    device = "/dev/disk/by-partuuid/<root-partition-partuuid>"; # from `lsblk -o NAME,PARTUUID` on shiro
    allowDiscards = true; # shiro root is an SSD
    bypassWorkqueues = true;
  };

  # b) initrd networking — shared by Clevis AND the manual SSH fallback.
  boot.initrd.availableKernelModules = [ "r8169" ]; # shiro NIC (jibril's is e1000e; different hardware)

  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 22;
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ]; # throwaway key, generated on-host — see reference doc
      authorizedKeys = map (
        key: ''command="systemctl default" ${key}''
      ) config.users.users.ggg.openssh.authorizedKeys.keys;
    };
  };

  # ip=client::gw:netmask:host:iface:autoconf
  boot.kernelParams = [
    "ip=${config.home.addrs.shiro-main}::${config.home.addrs.router}:255.255.0.0::enp6s0:none"
  ];

  # c) Clevis auto-unlock. The JWE ships via environment.etc, NOT as a
  # source path — see "How it actually unlocks" for why.
  environment.etc."clevis/root.jwe".source = ./root.jwe; # committed, see below
  boot.initrd.clevis.enable = true;
  boot.initrd.clevis.useTang = true;
  boot.initrd.clevis.devices."crypted-root".secretFile = "/etc/clevis/root.jwe";
}
```

Notes:

- `config.home.addrs.shiro-main` (**not** `.shiro` — that key doesn't exist),
  iface `enp6s0`, NIC module `r8169`. Confirmed against
  `hosts/shiro/networking/default.nix` and shiro's `facter.json`.
- Clevis reaches Tang at a raw `http://<jibril-ip>:7654` URL baked into the
  JWE at provisioning time — the **initrd needs no DNS resolver**, the static
  `ip=` kernel param above is sufficient network setup.
- `secretFile` must point at a real file that exists at flake-eval time — see
  Piece 3, step 5, for how it's produced.
- **No new `flake.nix` module registration needed** — `luks.nix` is a host-local
  file, not a shared `nixosModules` entry. `config.home.addrs` is already
  available on shiro via `self.nixosModules.home-network-addrs`.

## Piece 3 — migration (in-place, no spare drive)

Reuse `luks-root-encryption.md`'s "Deploying the migration itself" section for
the bulk of the mechanics (rescue/kexec + shrink + `cryptsetup reencrypt
--encrypt --reduce-device-size 32M --type luks2` + grow back; `nixos-enter` +
`switch-to-configuration boot` with `NIXOS_INSTALL_BOOTLOADER=1`; header
backup; reboot). The ZFS `storage` pool is untouched throughout — this
migration only touches the btrfs root partition.

**One important reordering versus the reference doc**, driven by `secretFile`
being a *build-time* path (see "How it actually unlocks" above): the reference
doc's step 2 ("make config changes, build only") happens *before* its step 5
(the actual reencrypt, where the LUKS passphrase gets set). That means the JWE
— which encrypts that passphrase — can't be generated from "the passphrase set
during reencrypt," because the build that needs to embed the JWE happens
*first*. The fix is to **predetermine the passphrase** rather than letting
`cryptsetup reencrypt` prompt for an arbitrary one on the spot, and provision
the JWE from it *before* building:

1. Back up first (reference doc step 1, unchanged).
2. **Decide the LUKS passphrase now** (don't defer this to the reencrypt
   prompt). With Tang already deployed and reachable on jibril (Piece 1 done
   first), provision the JWE from it:
   ```
   echo -n "<the chosen LUKS passphrase>" | \
     clevis encrypt tang '{"url":"http://10.0.2.2:7654"}' > hosts/shiro/root.jwe
   ```
   `clevis encrypt` fetches Tang's advertisement and prints the key
   thumbprint for confirmation — it should match the one already trusted
   when `storage.jwe` was provisioned (sanity-check against
   `curl http://10.0.2.2:7654/adv`). Commit `root.jwe` into the repo at the
   path referenced by `secretFile` above.
3. Make the config changes from Piece 2 (including the now-committed
   `secretFile` reference) and **build only** — reference doc step 2, never
   activate against the still-unencrypted disk.
4. Copy the closure to shiro and gcroot it (reference doc step 3).
5. Boot into rescue/kexec (reference doc step 4).
6. Shrink btrfs, then `cryptsetup reencrypt --encrypt ...`, entering **the
   same predetermined passphrase from step 2 above** when prompted — this is
   what makes the JWE (encrypted ahead of time in step 2) actually valid
   against the resulting LUKS header. Reopen and grow back (reference doc
   step 5).
7. Generate the throwaway initrd SSH host key on shiro (reference doc step 4's
   `ssh-keygen` instructions).
8. `nixos-enter`, activate the gcroot-pinned closure (reference doc step 6).
9. Back up the LUKS header off-machine (reference doc step 7) — header loss is
   total data loss regardless of Clevis.
10. Reboot. Expected: Clevis reaches jibril's Tang and auto-unlocks. If jibril
    is down, boot falls to the passphrase prompt, reachable via
    `./ssh-unlock shiro` (initrd-SSH) using the passphrase from step 2.

Rotating Tang's key later requires regenerating and recommitting the JWE (the
LUKS passphrase itself doesn't need to change for a Tang rotation).

Keep a physical USB installer on hand as a fallback, per the reference doc.

## Verification

Before deploying (evaluation-time, from the flake dir):

```bash
# LUKS device wiring present with the right mapper name
nix eval .#nixosConfigurations.shiro.config.boot.initrd.luks.devices --json

# initrd has the NIC driver, network, and clevis enabled + pointed at the right device
nix eval .#nixosConfigurations.shiro.config.boot.initrd.availableKernelModules --json
nix eval .#nixosConfigurations.shiro.config.boot.initrd.clevis.enable
nix eval .#nixosConfigurations.shiro.config.boot.initrd.clevis.useTang
nix eval --json .#nixosConfigurations.shiro.config.boot.initrd.network.ssh.authorizedKeys

# Tang wired on jibril with its fixed port, both firewall layers configured
nix eval .#nixosConfigurations.jibril.config.services.tang.listenStream --json
nix eval .#nixosConfigurations.jibril.config.services.tang.ipAddressAllow --json
nix eval .#nixosConfigurations.jibril.config.networking.firewall.allowedTCPPorts --json

# whole-fleet eval sanity
nix build .#ggg-all-systems
./nh-os.sh build shiro
./nh-os.sh build jibril
```

Post-deploy (behavioural):

```bash
# From another host on the LAN: Tang answers its advertisement
curl -s http://10.0.2.2:7654/adv | jq .

# Happy path: reboot shiro with jibril already up → it should come back with
# no interactive prompt (watch it come back on the network without an ssh-unlock).

# Fallback path: stop Tang on jibril (systemctl stop tangd.socket tangd@*),
# reboot shiro → it must NOT auto-unlock and must still be reachable at the
# passphrase prompt over the initrd-SSH escape hatch:
./ssh-unlock shiro   # then enter the passphrase manually
```
