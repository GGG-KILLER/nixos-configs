#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nix-update coreutils
# shellcheck shell=bash
set -euo pipefail

# Update packages nix-update supports
nix-update --flake --version unstable --format --commit jellyfin-unstable
nix-update --flake --version unstable --format --commit jellyfin-web-unstable
nix-update --flake --version unstable --format --commit ytmd


get-version() {
    nix-instantiate --eval -E "with import ./. {}; $1.version or (lib.getVersion $1)" | tr -d '"'
}

for script_path in packages/*/update.sh; do
    package_dir="$(dirname "$script_path")"
    package="$(basename "$package_dir")"

    old_ver="$(get-version "$package")"

    echo "$package: updating from $old_ver..."

    if ! pushd "$package_dir" > /dev/null; then
        echo "error"
        continue
    fi

    chmod +x update.sh > /dev/null;

    if ! ./update.sh; then
        echo "error"
        popd > /dev/null
        continue
    fi

    popd > /dev/null


    new_ver="$(get-version "$package")"

    if [ "$old_ver" == "$new_ver" ]; then
        echo "$package: no new version."
        continue
    fi

    echo "$package: $old_ver -> $new_ver"

    git add "$package_dir"
    git commit -m "$package: $old_ver -> $new_ver"
done
