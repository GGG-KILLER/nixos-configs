#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq common-updater-scripts nuget-to-nix gnugrep coreutils
# shellcheck shell=bash

set -euo pipefail
SDK7_VERSION=$(dotnet --version)
RUNTIME6_VERSION=$(dotnet --list-runtimes | grep -oP '(?<=Microsoft\.NETCore\.App )6\.0\.\d+')

replaceInPlace(){
    local contents
    contents=$(cat "$1")
    contents=${contents//$2/$3}
    echo "$contents">"$1"
}

cd "$(dirname "${BASH_SOURCE[0]}")"

deps_file="$(realpath "./deps.nix")"

new_version="$(curl -s "https://api.github.com/repos/OmniSharp/omnisharp-roslyn/releases?per_page=1" | jq -r '.[0].name')"
old_version="$(sed -nE 's/\s*version = "(.*)".*/\1/p' ./default.nix)"

if [[ "$new_version" == "$old_version" ]]; then
  echo "Already up to date!"
  exit 0
fi

update-source-version omnisharp-roslyn "${new_version//v}"
store_src="$(nix-build . -A omnisharp-roslyn.src --no-out-link)"
src="$(mktemp -d /tmp/omnisharp-roslyn-src.XXX)"

cp -rT "$store_src" "$src"
chmod -R +w "$src"
trap 'rm -r "$src"' EXIT

pushd "$src"

export DOTNET_NOLOGO=1
export DOTNET_CLI_TELEMETRY_OPTOUT=1

mkdir ./nuget_pkgs

replaceInPlace global.json '7.0.100-preview.4.22252.9' "$SDK7_VERSION"

for project in src/OmniSharp.Stdio.Driver/OmniSharp.Stdio.Driver.csproj; do
  dotnet restore "$project" \
    --packages ./nuget_pkgs \
    -property:PackageVersion="${new_version//v}" \
    -property:AssemblyVersion="${new_version//v}".0 \
    -property:FileVersion="${new_version//v}".0 \
    -property:InformationalVersion="${new_version//v}" \
    -property:RuntimeFrameworkVersion=6.0.0-preview.7.21317.1 \
    -property:RollForward=LatestMajor
done

nuget-to-nix ./nuget_pkgs > "$deps_file"