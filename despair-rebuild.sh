#! /usr/bin/env bash
# shellcheck shell=bash
set -xeuo pipefail

ROOT_DIR="$(dirname "$(readlink -f "$0")")"
mv "$ROOT_DIR/.git" "$ROOT_DIR/.git.bkp"
trap "mv '$ROOT_DIR/.git.bkp' '$ROOT_DIR/.git'" EXIT
sudo nixos-rebuild --flake "$ROOT_DIR" "$@"
