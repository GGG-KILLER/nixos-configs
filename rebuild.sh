#! /usr/bin/env nix-shell
#! nix-shell -i bash -p
# shellcheck shell=bash
ROOT_DIR="$(dirname "$(readlink -f "$0")")"
nixos-rebuild --use-remote-sudo --flake "$ROOT_DIR" "$@"