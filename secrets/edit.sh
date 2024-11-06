#! /usr/bin/env nix-shell
#! nix-shell -i bash -p vscode
# shellcheck shell=bash
ROOT_DIR="$(dirname "$(readlink -f "$0")")"
pushd "$ROOT_DIR" || exit
FILE_PATH="$1"
if [ -z "$FILE_PATH" ]; then
    echo "Usage: $0 [path]"
    exit 1
fi

if [ ! -f "$FILE_PATH" ] && [ -f "../$FILE_PATH" ]; then
    FILE_PATH=$(realpath -s --relative-to="$ROOT_DIR" "../$FILE_PATH")
fi

EDITOR="code --wait" exec agenix -e "$FILE_PATH"
