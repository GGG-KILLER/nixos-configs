#! /usr/bin/env nix-shell
#! nix-shell -i bash -p
# shellcheck shell=bash
ROOT_DIR="$(dirname "$(readlink -f "$0")")"
RULES="$ROOT_DIR/secrets.nix" EDITOR="code --wait" agenix -e "$@"