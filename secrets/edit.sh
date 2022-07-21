#! /usr/bin/env nix-shell
#! nix-shell -i bash -p
# shellcheck shell=bash
EDITOR="code --wait" agenix -e "$@"