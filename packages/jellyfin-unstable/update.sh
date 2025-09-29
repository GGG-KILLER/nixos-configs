#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts gnused nix coreutils
# shellcheck shell=bash

set -euo pipefail

latestVersion="$(curl -s "https://api.github.com/repos/jellyfin/jellyfin/releases?per_page=1" | jq -r ".[0].tag_name" | sed 's/^v//')"
currentVersion=$(nix-instantiate --eval -E "with import ./. {}; jellyfin-unstable.version or (lib.getVersion jellyfin-unstable)" | tr -d '"')

if [[ "$currentVersion" == "$latestVersion" ]]; then
  echo "jellyfin-unstable is up-to-date: $currentVersion"
  exit 0
fi

update-source-version jellyfin-unstable "$latestVersion"

eval "$(nix-build . -A jellyfin-unstable.fetch-deps --no-out-link)"
