#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nh
# shellcheck shell=bash
ROOT_DIR="$(dirname "$(readlink -f "$0")")"
COMMAND="$1"
shift 1
exec nh os "$COMMAND" "$ROOT_DIR" "$@"