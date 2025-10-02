#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curl common-updater-scripts gnugrep gnused nix coreutils
# shellcheck shell=bash

set -euo pipefail

get-hash() {
    nix hash convert --hash-algo sha256 "$(nix-prefetch-url --type sha256 "$1")"
}

latestVersion="$(curl -s https://mikrotik.com/download | grep -oE 'https://download.mikrotik.com/routeros/winbox/4[^/]+/WinBox_Linux.zip' | grep -oE '4[^/]+')"
currentVersion=$(nix-instantiate --eval -E "with import ./. {}; winbox4.version or (lib.getVersion winbox4)" | tr -d '"')

if [[ "$currentVersion" == "$latestVersion" ]]; then
  echo "winbox4 is up-to-date: $currentVersion"
  exit 0
fi

linuxHash="$(get-hash https://download.mikrotik.com/routeros/winbox/$latestVersion/WinBox_Linux.zip)"
darwinHash="$(get-hash https://download.mikrotik.com/routeros/winbox/$latestVersion/WinBox_Linux.zip)"

update-source-version winbox4 "$latestVersion" "$linuxHash" --system=x86_64-linux --ignore-same-version
update-source-version winbox4 "$latestVersion" "$darwinHash" --system=aarch64-darwin --ignore-same-version
