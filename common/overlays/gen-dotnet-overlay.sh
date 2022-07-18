#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq
set -eu

RELEASES_INDEX_FILE=""
VERSION_RELEASES_JSON_FILE=""
function cleanup() {
    [ ! \( -z "$RELEASES_INDEX_FILE" \) ] && rm "$RELEASES_INDEX_FILE";
    [ ! \( -z "$VERSION_RELEASES_JSON_FILE" \) ] && rm "$VERSION_RELEASES_JSON_FILE";
}
function usage() {
    echo "Usage: $0 [version]" >&2;
    echo >&2;
    printf "\tWhere version is a .NET version (e.g.: 6.0, 7.0).\n" >&2
    printf "\tFile will be output to dotnet-\$VERSION.nix\n" >&2
}
trap cleanup EXIT

if [[ $# != 1 ]]; then
    usage
    echo "Error: No arguments provided." >&2
    exit 1
fi

WANTED_VERSION=$1

if [[ ! ( $WANTED_VERSION =~ ^[[:digit:]]+\.[[:digit:]]+$ ) ]]; then
    usage
    echo "Error: Provided version was in an unrecognized format." >&2
    echo "       Expected version in format MAJOR.MINOR (e.g.: 7.0)." >&2
    exit 1
fi;

if [[ "$WANTED_VERSION" == "--help" || "$WANTED_VERSION" == "-h" ]]; then
    usage
    exit 1
fi

RELEASES_INDEX_FILE=$(mktemp dotnet-releases-index-XXXXXX.json)
curl -s "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json" -o "$RELEASES_INDEX_FILE" || (
    echo "Error fetching releases-index.json"
    exit 1
)
VERSION_RELEASES_JSON_URL=$(jq -r ".[\"releases-index\"][] | select(.[\"channel-version\"] == \"$WANTED_VERSION\") | .[\"releases.json\"]" "$RELEASES_INDEX_FILE")

if [ -z "$VERSION_RELEASES_JSON_URL" ]; then
    echo "Version not found in releases."
    exit 1
fi

VERSION_RELEASES_JSON_FILE=$(mktemp "dotnet-$WANTED_VERSION-releases-XXXXXX.json")
curl -s "$VERSION_RELEASES_JSON_URL" -o "$VERSION_RELEASES_JSON_FILE" || (
    echo "Error downloading releases.json"
    exit 1
)

ASPNETCORE_VERSION=$(jq -r '.releases[0]["aspnetcore-runtime"].version' "$VERSION_RELEASES_JSON_FILE")
ASPNETCORE_LINUX_X86_64_URL=$(jq -r '.releases[0]["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-linux-x64.tar.gz") | .url' "$VERSION_RELEASES_JSON_FILE")
ASPNETCORE_LINUX_X86_64_HASH=$(jq -r '.releases[0]["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-linux-x64.tar.gz") | .hash' "$VERSION_RELEASES_JSON_FILE")
ASPNETCORE_LINUX_AARCH64_URL=$(jq -r '.releases[0]["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-linux-arm64.tar.gz") | .url' "$VERSION_RELEASES_JSON_FILE")
ASPNETCORE_LINUX_AARCH64_HASH=$(jq -r '.releases[0]["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-linux-arm64.tar.gz") | .hash' "$VERSION_RELEASES_JSON_FILE")
ASPNETCORE_DARWIN_X86_64_URL=$(jq -r '.releases[0]["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-osx-x64.tar.gz") | .url' "$VERSION_RELEASES_JSON_FILE")
ASPNETCORE_DARWIN_X86_64_HASH=$(jq -r '.releases[0]["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-osx-x64.tar.gz") | .hash' "$VERSION_RELEASES_JSON_FILE")
ASPNETCORE_DARWIN_AARCH64_URL=$(jq -r '.releases[0]["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-osx-arm64.tar.gz") | .url' "$VERSION_RELEASES_JSON_FILE")
ASPNETCORE_DARWIN_AARCH64_HASH=$(jq -r '.releases[0]["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-osx-arm64.tar.gz") | .hash' "$VERSION_RELEASES_JSON_FILE")

RUNTIME_VERSION=$(jq -r '.releases[0].runtime.version' "$VERSION_RELEASES_JSON_FILE")
RUNTIME_LINUX_X86_64_URL=$(jq -r '.releases[0].runtime.files[] | select(.name == "dotnet-runtime-linux-x64.tar.gz") | .url' "$VERSION_RELEASES_JSON_FILE")
RUNTIME_LINUX_X86_64_HASH=$(jq -r '.releases[0].runtime.files[] | select(.name == "dotnet-runtime-linux-x64.tar.gz") | .hash' "$VERSION_RELEASES_JSON_FILE")
RUNTIME_LINUX_AARCH64_URL=$(jq -r '.releases[0].runtime.files[] | select(.name == "dotnet-runtime-linux-arm64.tar.gz") | .url' "$VERSION_RELEASES_JSON_FILE")
RUNTIME_LINUX_AARCH64_HASH=$(jq -r '.releases[0].runtime.files[] | select(.name == "dotnet-runtime-linux-arm64.tar.gz") | .hash' "$VERSION_RELEASES_JSON_FILE")
RUNTIME_DARWIN_X86_64_URL=$(jq -r '.releases[0].runtime.files[] | select(.name == "dotnet-runtime-osx-x64.tar.gz") | .url' "$VERSION_RELEASES_JSON_FILE")
RUNTIME_DARWIN_X86_64_HASH=$(jq -r '.releases[0].runtime.files[] | select(.name == "dotnet-runtime-osx-x64.tar.gz") | .hash' "$VERSION_RELEASES_JSON_FILE")
RUNTIME_DARWIN_AARCH64_URL=$(jq -r '.releases[0].runtime.files[] | select(.name == "dotnet-runtime-osx-arm64.tar.gz") | .url' "$VERSION_RELEASES_JSON_FILE")
RUNTIME_DARWIN_AARCH64_HASH=$(jq -r '.releases[0].runtime.files[] | select(.name == "dotnet-runtime-osx-arm64.tar.gz") | .hash' "$VERSION_RELEASES_JSON_FILE")

SDK_VERSION=$(jq -r '.releases[0].sdk.version' "$VERSION_RELEASES_JSON_FILE")
SDK_LINUX_X86_64_URL=$(jq -r '.releases[0].sdk.files[] | select(.name == "dotnet-sdk-linux-x64.tar.gz") | .url' "$VERSION_RELEASES_JSON_FILE")
SDK_LINUX_X86_64_HASH=$(jq -r '.releases[0].sdk.files[] | select(.name == "dotnet-sdk-linux-x64.tar.gz") | .hash' "$VERSION_RELEASES_JSON_FILE")
SDK_LINUX_AARCH64_URL=$(jq -r '.releases[0].sdk.files[] | select(.name == "dotnet-sdk-linux-arm64.tar.gz") | .url' "$VERSION_RELEASES_JSON_FILE")
SDK_LINUX_AARCH64_HASH=$(jq -r '.releases[0].sdk.files[] | select(.name == "dotnet-sdk-linux-arm64.tar.gz") | .hash' "$VERSION_RELEASES_JSON_FILE")
SDK_DARWIN_X86_64_URL=$(jq -r '.releases[0].sdk.files[] | select(.name == "dotnet-sdk-osx-x64.tar.gz") | .url' "$VERSION_RELEASES_JSON_FILE")
SDK_DARWIN_X86_64_HASH=$(jq -r '.releases[0].sdk.files[] | select(.name == "dotnet-sdk-osx-x64.tar.gz") | .hash' "$VERSION_RELEASES_JSON_FILE")
SDK_DARWIN_AARCH64_URL=$(jq -r '.releases[0].sdk.files[] | select(.name == "dotnet-sdk-osx-arm64.tar.gz") | .url' "$VERSION_RELEASES_JSON_FILE")
SDK_DARWIN_AARCH64_HASH=$(jq -r '.releases[0].sdk.files[] | select(.name == "dotnet-sdk-osx-arm64.tar.gz") | .hash' "$VERSION_RELEASES_JSON_FILE")

FORMATTED_VERSION=${WANTED_VERSION//./_}

cat >"dotnet-$WANTED_VERSION.nix" <<DELIM
{nixpkgs, ...}: {
  nixpkgs.overlays = [
    (self: super: let
      # Use \`import <nixpkgs/pkgs/development/compilers/dotnet/build-dotnet.nix>\` if you're not using nix flakes.
      buildDotnet = attrs: super.callPackage (import "\${nixpkgs}/pkgs/development/compilers/dotnet/build-dotnet.nix" attrs) {};
      buildAspNetCore = attrs: buildDotnet (attrs // {type = "aspnetcore";});
      buildNetRuntime = attrs: buildDotnet (attrs // {type = "runtime";});
      buildNetSdk = attrs: buildDotnet (attrs // {type = "sdk";});
    in {
      dotnetCorePackages =
        super.dotnetCorePackages
        // {
          # v$WANTED_VERSION (preview)
          aspnetcore_$FORMATTED_VERSION = buildAspNetCore {
            icu = super.icu;
            version = "$ASPNETCORE_VERSION";
            srcs = {
              x86_64-linux = {
                url = "$ASPNETCORE_LINUX_X86_64_URL";
                sha512 = "$ASPNETCORE_LINUX_X86_64_HASH";
              };
              aarch64-linux = {
                url = "$ASPNETCORE_LINUX_AARCH64_URL";
                sha512 = "$ASPNETCORE_LINUX_AARCH64_HASH";
              };
              x86_64-darwin = {
                url = "$ASPNETCORE_DARWIN_X86_64_URL";
                sha512 = "$ASPNETCORE_DARWIN_X86_64_HASH";
              };
              aarch64-darwin = {
                url = "$ASPNETCORE_DARWIN_AARCH64_URL";
                sha512 = "$ASPNETCORE_DARWIN_AARCH64_HASH";
              };
            };
          };

          runtime_$FORMATTED_VERSION = buildNetRuntime {
            icu = super.icu;
            version = "$RUNTIME_VERSION";
            srcs = {
              x86_64-linux = {
                url = "$RUNTIME_LINUX_X86_64_URL";
                sha512 = "$RUNTIME_LINUX_X86_64_HASH";
              };
              aarch64-linux = {
                url = "$RUNTIME_LINUX_AARCH64_URL";
                sha512 = "$RUNTIME_LINUX_AARCH64_HASH";
              };
              x86_64-darwin = {
                url = "$RUNTIME_DARWIN_X86_64_URL";
                sha512 = "$RUNTIME_DARWIN_X86_64_HASH";
              };
              aarch64-darwin = {
                url = "$RUNTIME_DARWIN_AARCH64_URL";
                sha512 = "$RUNTIME_DARWIN_AARCH64_HASH";
              };
            };
          };

          sdk_$FORMATTED_VERSION = buildNetSdk {
            icu = super.icu;
            version = "$SDK_VERSION";
            srcs = {
              x86_64-linux = {
                url = "$SDK_LINUX_X86_64_URL";
                sha512 = "$SDK_LINUX_X86_64_HASH";
              };
              aarch64-linux = {
                url = "$SDK_LINUX_AARCH64_URL";
                sha512 = "$SDK_LINUX_AARCH64_HASH";
              };
              x86_64-darwin = {
                url = "$SDK_DARWIN_X86_64_URL";
                sha512 = "$SDK_DARWIN_X86_64_HASH";
              };
              aarch64-darwin = {
                url = "$SDK_DARWIN_AARCH64_URL";
                sha512 = "$SDK_DARWIN_AARCH64_HASH";
              };
            };
          };
        };
    })
  ];
}
DELIM