#!/usr/bin/env bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
NIXOS_CONFIG=$SCRIPT_DIR/servers/$1
echo NIXOS_CONFIG=$NIXOS_CONFIG
nix repl '<nixpkgs>' '<nixpkgs/nixos>' -I "nixos-config=${NIXOS_CONFIG}"
