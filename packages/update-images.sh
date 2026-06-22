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

    write-image "eclipse-mosquitto" "2.1-alpine"
    write-image "redis"
    write-image "evazion/iqdb"
    write-image "gggdotdev/netprobesharp"
    write-image "jlesage/jdownloader-2"
    write-image "klausmeyer/docker-registry-browser"
    write-image "plaintextpackets/netprobe"
    write-image "zer0tonin/mikochi"
    write-image "docker.lan/downloader/backend"
    write-image "docker.lan/downloader/frontend"
    write-image "ghcr.io/danbooru/autotagger"
    write-image "ghcr.io/danbooru/danbooru" "master"
    write-image "ghcr.io/home-assistant/home-assistant" "stable"
    write-image "ghcr.io/koenkk/zigbee2mqtt"
    write-image "ghcr.io/suwayomi/suwayomi-server"
    write-image "ghcr.io/thephaseless/byparr"

    echo '}'
} > "$ROOT_DIR/docker-images.nix"
nixfmt "$ROOT_DIR/docker-images.nix"
