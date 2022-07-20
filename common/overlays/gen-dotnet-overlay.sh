#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq
# shellcheck shell=bash
set -euo pipefail

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
fi

if [[ "$WANTED_VERSION" == "--help" || "$WANTED_VERSION" == "-h" ]]; then
    usage
    exit 1
fi

RELEASES_INDEX=$(curl -sL "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json")
VERSION_RELEASES_JSON_URL=$(jq -r ".[\"releases-index\"][] | select(.[\"channel-version\"] == \"$WANTED_VERSION\") | .[\"releases.json\"]" <<< "$RELEASES_INDEX")

if [ -z "$VERSION_RELEASES_JSON_URL" ]; then
    echo "Version not found in releases."
    exit 1
fi

VERSION_RELEASES_JSON=$(curl -sL "$VERSION_RELEASES_JSON_URL")
LATEST_RELEASE=$(jq '.releases[0]' <<< "$VERSION_RELEASES_JSON")

ASPNETCORE_VERSION=$(jq -r '.["aspnetcore-runtime"].version' <<< "$LATEST_RELEASE")
ASPNETCORE_LINUX_X86_64_URL=$(jq -r '.["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-linux-x64.tar.gz") | .url' <<< "$LATEST_RELEASE")
ASPNETCORE_LINUX_X86_64_HASH=$(jq -r '.["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-linux-x64.tar.gz") | .hash' <<< "$LATEST_RELEASE")
ASPNETCORE_LINUX_AARCH64_URL=$(jq -r '.["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-linux-arm64.tar.gz") | .url' <<< "$LATEST_RELEASE")
ASPNETCORE_LINUX_AARCH64_HASH=$(jq -r '.["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-linux-arm64.tar.gz") | .hash' <<< "$LATEST_RELEASE")
ASPNETCORE_DARWIN_X86_64_URL=$(jq -r '.["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-osx-x64.tar.gz") | .url' <<< "$LATEST_RELEASE")
ASPNETCORE_DARWIN_X86_64_HASH=$(jq -r '.["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-osx-x64.tar.gz") | .hash' <<< "$LATEST_RELEASE")
ASPNETCORE_DARWIN_AARCH64_URL=$(jq -r '.["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-osx-arm64.tar.gz") | .url' <<< "$LATEST_RELEASE")
ASPNETCORE_DARWIN_AARCH64_HASH=$(jq -r '.["aspnetcore-runtime"].files[] | select(.name == "aspnetcore-runtime-osx-arm64.tar.gz") | .hash' <<< "$LATEST_RELEASE")

RUNTIME_VERSION=$(jq -r '.runtime.version' <<< "$LATEST_RELEASE")
RUNTIME_LINUX_X86_64_URL=$(jq -r '.runtime.files[] | select(.name == "dotnet-runtime-linux-x64.tar.gz") | .url' <<< "$LATEST_RELEASE")
RUNTIME_LINUX_X86_64_HASH=$(jq -r '.runtime.files[] | select(.name == "dotnet-runtime-linux-x64.tar.gz") | .hash' <<< "$LATEST_RELEASE")
RUNTIME_LINUX_AARCH64_URL=$(jq -r '.runtime.files[] | select(.name == "dotnet-runtime-linux-arm64.tar.gz") | .url' <<< "$LATEST_RELEASE")
RUNTIME_LINUX_AARCH64_HASH=$(jq -r '.runtime.files[] | select(.name == "dotnet-runtime-linux-arm64.tar.gz") | .hash' <<< "$LATEST_RELEASE")
RUNTIME_DARWIN_X86_64_URL=$(jq -r '.runtime.files[] | select(.name == "dotnet-runtime-osx-x64.tar.gz") | .url' <<< "$LATEST_RELEASE")
RUNTIME_DARWIN_X86_64_HASH=$(jq -r '.runtime.files[] | select(.name == "dotnet-runtime-osx-x64.tar.gz") | .hash' <<< "$LATEST_RELEASE")
RUNTIME_DARWIN_AARCH64_URL=$(jq -r '.runtime.files[] | select(.name == "dotnet-runtime-osx-arm64.tar.gz") | .url' <<< "$LATEST_RELEASE")
RUNTIME_DARWIN_AARCH64_HASH=$(jq -r '.runtime.files[] | select(.name == "dotnet-runtime-osx-arm64.tar.gz") | .hash' <<< "$LATEST_RELEASE")

SDK_VERSION=$(jq -r '.sdk.version' <<< "$LATEST_RELEASE")
SDK_LINUX_X86_64_URL=$(jq -r '.sdk.files[] | select(.name == "dotnet-sdk-linux-x64.tar.gz") | .url' <<< "$LATEST_RELEASE")
SDK_LINUX_X86_64_HASH=$(jq -r '.sdk.files[] | select(.name == "dotnet-sdk-linux-x64.tar.gz") | .hash' <<< "$LATEST_RELEASE")
SDK_LINUX_AARCH64_URL=$(jq -r '.sdk.files[] | select(.name == "dotnet-sdk-linux-arm64.tar.gz") | .url' <<< "$LATEST_RELEASE")
SDK_LINUX_AARCH64_HASH=$(jq -r '.sdk.files[] | select(.name == "dotnet-sdk-linux-arm64.tar.gz") | .hash' <<< "$LATEST_RELEASE")
SDK_DARWIN_X86_64_URL=$(jq -r '.sdk.files[] | select(.name == "dotnet-sdk-osx-x64.tar.gz") | .url' <<< "$LATEST_RELEASE")
SDK_DARWIN_X86_64_HASH=$(jq -r '.sdk.files[] | select(.name == "dotnet-sdk-osx-x64.tar.gz") | .hash' <<< "$LATEST_RELEASE")
SDK_DARWIN_AARCH64_URL=$(jq -r '.sdk.files[] | select(.name == "dotnet-sdk-osx-arm64.tar.gz") | .url' <<< "$LATEST_RELEASE")
SDK_DARWIN_AARCH64_HASH=$(jq -r '.sdk.files[] | select(.name == "dotnet-sdk-osx-arm64.tar.gz") | .hash' <<< "$LATEST_RELEASE")

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