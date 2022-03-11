#! /usr/bin/env bash

set -e

network="$(dirname "${BASH_SOURCE[0]}")/network.nix"
ident_file="$(dirname "${BASH_SOURCE[0]}")/deploy.privkey"

morph build --keep-result "$network"
SSH_IDENTITY_FILE="$ident_file" morph push "$network"
SSH_IDENTITY_FILE="$ident_file" morph deploy "$network" switch