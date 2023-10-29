#! /usr/bin/env nix-shell
#! nix-shell -i bash -p
# shellcheck shell=bash
exec deploy --keep-result --checksigs "$@"