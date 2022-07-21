#! /usr/bin/env nix-shell
#! nix-shell -i bash -p
# shellcheck shell=bash
nixos-rebuild --use-remote-sudo "$@"