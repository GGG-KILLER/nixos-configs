#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nix-prefetch-docker nixfmt
# shellcheck shell=bash
set -euo pipefail

ROOT_DIR="$(dirname "$(readlink -f "$0")")"

function write-image() {
    local IMAGE_NAME="$1"
    local IMAGE_TAG="${2-latest}"

    {
        echo -n '"'"${IMAGE_NAME}:${IMAGE_TAG}"'"'" = dockerTools.pullImage "
        nix-prefetch-docker -- --image-name "$IMAGE_NAME" --image-tag "$IMAGE_TAG" --arch amd64 --os linux --quiet
        echo ';'
    }
}

{
    echo '{ dockerTools }:{'

    write-image "eclipse-mosquitto" "2.0"
    write-image "redis"
    write-image "evazion/iqdb"
    write-image "klausmeyer/docker-registry-browser"
    write-image "plaintextpackets/netprobe"
    write-image "zer0tonin/mikochi"
    write-image "docker.lan/downloader/backend"
    write-image "docker.lan/downloader/frontend"
    write-image "ghcr.io/danbooru/autotagger"
    write-image "ghcr.io/danbooru/danbooru" "master"

    echo '}'
} > "$ROOT_DIR/docker-images.nix"
nixfmt "$ROOT_DIR/docker-images.nix"
