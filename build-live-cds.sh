#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nix nix-output-monitor
# shellcheck shell=bash
set -euo pipefail

if [ -d isos/ ]; then
    rm -f isos/*.iso || true
else
    mkdir isos
fi

function move_iso() {
    ISOS=("$1"/iso/*.iso)
    ISO_PATH="${ISOS[0]}"
    ISO_NAME="$(basename "$ISO_PATH")"
    cp "$ISO_PATH" "$ISO_NAME"
    chown "$(id -u):$(id -g)" "$ISO_NAME"
    chmod a=r "$ISO_NAME"
}

pushd isos
(
    echo Creating GNOME ISO...
    nom build ..#nixosConfigurations.live-cd-plasma6.config.system.build.isoImage -o gnome --quiet
    move_iso gnome

    echo Creating Minimal ISO...
    nom build ..#nixosConfigurations.live-cd-minimal.config.system.build.isoImage -o minimal --quiet
    move_iso minimal
)
popd
