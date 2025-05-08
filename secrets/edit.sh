#! /usr/bin/env nix-shell
#! nix-shell -i bash -p vscode
# shellcheck shell=bash
if [[ -z "$1" ]]; then
    echo "Usage: $0 [path]"
    exit 1
fi

ROOT_DIR="$(dirname "$(readlink -f "$0")")"
FILE_PATH="$(realpath -s --relative-to="$ROOT_DIR" "$1")"

pushd "$ROOT_DIR" || exit
EDITOR="code --wait" exec agenix -e "$FILE_PATH"
