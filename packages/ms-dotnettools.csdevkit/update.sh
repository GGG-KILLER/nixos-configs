#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl coreutils jq nix unzip
# shellcheck shell=bash
set -euo pipefail
shopt -s globstar

export LC_ALL=C

PUBLISHER=ms-dotnettools
EXTENSION=csdevkit
LOCKFILE=packages/$PUBLISHER.$EXTENSION/lockfile.json

response=$(curl -s 'https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery' \
    -H 'accept: application/json;api-version=3.0-preview.1' \
    -H 'content-type: application/json' \
    --data-raw '{"filters":[{"criteria":[{"filterType":7,"value":"'"$PUBLISHER.$EXTENSION"'"}]}],"flags":16}')

# Find the latest version compatible with stable vscode version
latest_version=$(jq --raw-output '
.results[0].extensions[0].versions
| map(select(has("properties")))
| map(select(.properties | map(select(.key == "Microsoft.VisualStudio.Code.Engine")) | .[0].value | test("\\^[0-9.]+$")))
| .[0].version' <<<"$response")

current_version=$(jq '.version' --raw-output <"$LOCKFILE")

if [[ "$latest_version" == "$current_version" ]]; then
    echo "Package is up to date." >&2
    exit 1
fi

getDownloadUrl() {
    nix-instantiate \
        --eval \
        --strict \
        --json \
        '<nixpkgs/pkgs/applications/editors/vscode/extensions/mktplcExtRefToFetchArgs.nix>' \
        --attr url \
        --argstr publisher $PUBLISHER \
        --argstr name $EXTENSION \
        --argstr version "$latest_version" \
        --argstr arch "$1" | jq . --raw-output
}

TEMP=$(mktemp --directory --tmpdir)
OUTPUT="$TEMP/lockfile.json"
trap 'rm -r "$TEMP"' EXIT

HASH=
fetchMarketplace() {
    arch="$1"

    echo "  Downloading VSIX..."
    if ! curl -sLo "$TEMP/$arch".zip "$(getDownloadUrl "$arch")"; then
        echo "    Failed to download extension for arch $arch" >&2
        exit 1
    fi

    HASH=$(nix hash file --type sha256 --sri "$TEMP/$arch".zip)
}

cat >"$OUTPUT" <<EOF
{
  "version": "$latest_version",
EOF
firstArch=true
for arch in linux-x64 linux-arm64 darwin-x64 darwin-arm64; do
    if [ "$firstArch" = false ]; then
        echo -e ',' >>"$OUTPUT"
    fi
    firstArch=false

    echo "Getting data for $arch..."
    fetchMarketplace "$arch"

    cat >>"$OUTPUT" <<EOF
  "$arch": "$HASH"
EOF
done
echo -e '\n}' >>"$OUTPUT"

mv "$OUTPUT" "$LOCKFILE"
