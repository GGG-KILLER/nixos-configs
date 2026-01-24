#! /usr/bin/env nix-shell
#! nix-shell -i bash -p
# shellcheck shell=bash
ROOT_DIR="$(dirname "$(readlink -f "$0")")"
exec deploy \
    --keep-result \
    --result-path "$ROOT_DIR/.deploy-gc" \
    --checksigs \
    --skip-checks \
    "$@"
