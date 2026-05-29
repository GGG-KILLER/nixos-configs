#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nix-update coreutils jq
# shellcheck shell=bash
set -euo pipefail

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

get-images-digests() {
    nix-instantiate --eval --strict --json -E 'with import ./. {}; builtins.removeAttrs (builtins.mapAttrs (_: img: img.drvAttrs.imageDigest) docker-images) ["override" "overrideDerivation"]'
}

old_digests="$(get-images-digests)"

packages/update-images.sh

new_digests="$(get-images-digests)"

changes="$(jq -rn \
    --argjson old "$old_digests" \
    --argjson new "$new_digests" \
    '($new | keys_unsorted[]) as $k |
     select($old[$k] != $new[$k]) |
     "- \($k): \($old[$k]) -> \($new[$k])"'
)"

if [ -n "$changes" ]; then
    git add packages/docker-images.nix
    git commit -m "$(printf 'docker-images.nix: update images\n%s' "$changes")"
else
    echo "docker-images.nix: no changes."
fi
