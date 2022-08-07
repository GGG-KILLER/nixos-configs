#! /usr/bin/env nix-shell
#! nix-shell -i bash -p vscode
# shellcheck shell=bash
ROOT_DIR="$(dirname "$(readlink -f "$0")")"
pushd "$ROOT_DIR" || exit
EDITOR="code --wait" agenix -e "$@"