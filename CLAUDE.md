# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is a personal NixOS flake managing several machines. Everything is `x86_64-linux`.

## Commands

Building and switching is done through the **`./nh-os.sh`** wrapper (around [`nh`](https://github.com/nix-community/nh)), not raw `nixos-rebuild`:

```bash
./nh-os.sh <subcommand> <host> [nh options...]   # subcommand = any `nh os` subcommand: build | switch | boot | test ...
                                                 # host       = flake host name; also its DNS name (<host>.lan)
./nh-os.sh build steph        # build a host, no activation
./nh-os.sh switch jibril      # build + activate; auto-adds --target-host jibril.lan when host != current machine
./nh-os.sh switch             # host defaults to `hostname` (current machine)
```

`nh-os.sh` writes GC roots to `.gc/<host>`. Remote deploys are inferred from the host name differing from the local hostname.

```bash
# Build every host's toplevel at once (CI-style "does it all evaluate" check)
nix build .#ggg-all-systems

# Build a single package output
nix build .#<package-name>

# Build the installer ISOs (Plasma 6 + minimal) into ./isos/
./build-live-cds.sh

# Bump all packages that have a packages/<name>/update.sh, plus docker image digests,
# committing each change individually
./update-packages.sh

# Edit an agenix secret (wraps `agenix -e` with repo root + VS Code)
./secrets/edit.sh secrets/<path>.age

# Update flake inputs
nix flake update [<input>]
```

There is no test suite — verification is "does it build" via `./nh-os.sh build <host>` or `nix build .#ggg-all-systems`. Nix files follow `nixfmt` formatting; it is not wired into the flake (no `nix fmt`) — it runs as the VS Code default formatter with format-on-save. Run `nixfmt <file>` manually to match the style.

## Architecture

### Flake entrypoint (`flake.nix`)
- `mkConfig file` builds a `nixosSystem`. It injects `specialArgs = { self; system; inputs; liveCd; }` (also passed to home-manager via `extraSpecialArgs`), and always prepends the `pog` overlay, `disko`, `./common`, `agenix`, and `home-manager` modules. `liveCd` is `true` when the host file lives under `./media`.
- `nixosConfigurations`: the four hosts (`sora`, `steph`, `shiro`, `jibril`) plus two installer images (`live-cd-plasma6`, `live-cd-minimal`).
- `nixosModules.*`: shared modules are re-exported here by name so hosts/profiles can pull them via `self.nixosModules.<name>` rather than relative paths.
- `packages`: auto-discovered from `./packages` with `lib.packagesFromDirectoryRecursive` for x86_64-linux, aarch64-linux, aarch64-darwin. `ggg-all-systems` is a `linkFarm` of every host's `system.build.toplevel`. (`default.nix` at the root exposes the same packages for `import ./.`, used by the update scripts.)

### Hosts (`hosts/<host>/`)
Each host's `configuration.nix` is the file passed to `mkConfig`. Hosts compose by importing a **profile** module (`self.nixosModules.desktop-profile` or `server-profile`) plus opt-in feature modules. Newer hosts (`sora`, `jibril`) split config into `./hardware`, `./system`, `./users/ggg` subdirectories; older ones (`shiro`) keep flatter `*.nix` files. Hardware is described via [nixos-facter](https://github.com/nix-community/nixos-facter) `facter.json` reports where possible.

Hosts: `shiro` = NAS, `jibril` = home server (most hosted services live under `hosts/jibril/system/services/`), `sora` = desktop/Steam-Deck-like, `steph` = laptop.

### Modules (`modules/`)
Shared modules are exported through `flake.nix`'s `nixosModules` and imported by name. Two **profiles** (`modules/desktop/profile.nix`, `modules/server/profile.nix`) bundle the common set (`common-programs`, `ggg-password`, `ggg-programs`, `groups`, `i18n`, `nix-settings`, `users`, `zsh`, etc.); hosts import a profile then add extras.

Custom options live under the **`ggg.*` namespace** (e.g. `ggg.angrr.enable`). When adding configurable behavior, follow this convention: define `options.ggg.<feature>` with `mkEnableOption` and gate `config` behind `mkIf`.

### Packages (`packages/`)
Auto-discovered — adding a `.nix` file (or a directory with `package.nix`) under `packages/` exposes a new flake package; no registration needed. Shell-script tools are written with [`pog`](https://github.com/jpetrucciani/pog) (the overlay is always present), e.g. `packages/batwhich.nix`. A package can ship a `packages/<name>/update.sh` to participate in `./update-packages.sh`. `lib/` helpers (`makeDesktopIcon`, `copyDesktopIcons`) are overlaid via `callPackage`.

### Secrets — two systems
1. **agenix** (`secrets/`): age-encrypted `.age` files. `secrets/secrets.nix` maps each file to the host SSH public keys allowed to decrypt it (`ggg` = personal key; per-host keys; `pcs`/`servers`/`all` groups). When adding a secret to a host, add its entry here with the right `publicKeys`, then edit via `./secrets/edit.sh`.
2. **git-crypt-agessh** (`common/secrets/`): "not-so-secret" values kept out of public view, transparently decrypted via git-crypt. Imported by `./common` on all non-liveCd builds.

## Conventions
- Reference shared modules by `self.nixosModules.<name>`, not relative imports, when crossing the host/module boundary.
- `liveCd` is available as a module argument to skip host-only config for installer images.
- License note: everything is MIT **except files under `hosts/sora/system/desktop/opensnitch/reject`**.
