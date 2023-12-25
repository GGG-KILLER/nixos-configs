#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nix
# shellcheck shell=bash
set -euo pipefail

rm isos/*.iso || true;
mkdir isos || true;

function move_iso() {
    ISOS=("$1"/iso/*.iso)
    ISO_PATH="${ISOS[0]}"
    ISO_NAME="$(basename "$ISO_PATH")"
    cp "$ISO_PATH" "$ISO_NAME";
    chown "$(id -u):$(id -g)" "$ISO_NAME"
    chmod a=r "$ISO_NAME"
}

pushd isos;
    echo Creating GNOME ISO...
    nix build ..#nixosConfigurations.live-cd-gnome.config.system.build.isoImage -o gnome --quiet;
    move_iso gnome;

    echo Creating Minimal ISO...
    nix build ..#nixosConfigurations.live-cd-minimal.config.system.build.isoImage -o minimal --quiet;
    move_iso minimal;
popd;