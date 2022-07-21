#! /usr/bin/env nix-shell
#! nix-shell -i bash -p
# shellcheck shell=bash
deploy --keep-result --checksigs "$@"