#! /usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || -z $1 ]]; then
	echo "Usage: $0 [host]"
	exit 1
fi

mv .git .g
trap 'mv .g .git' EXIT

nixos-install --root /mnt --flake .#"$1" --no-channel-copy --no-root-password
