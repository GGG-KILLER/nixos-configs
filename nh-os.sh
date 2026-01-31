#! /usr/bin/env nix-shell
#! nix-shell -i bash -p uutils-coreutils-noprefix nh
# shellcheck shell=bash
set -euo pipefail

usage() {
    >&2 echo "$0 <subcommand> <host> [OPTIONS...]"
    >&2 echo
    >&2 echo "    <subcommand>: one of \`nh os\`'s subcommands"
    >&2 echo "    <host>: the name of the host in the flake as well as its DNS name without the .lan prefix"
    >&2 echo "    [OPTIONS]: other optons that will be passed straight to \`nh os\`"
    exit 1
}

if [[ "${1:-}" == "--help" ]]; then
    usage
fi

if [ $# -lt 1 ]; then
    >&2 echo "error: not enough arguments provided"
    usage
fi

# Load args and script dir
ROOT_DIR="$(dirname "$(readlink -f "$0")")"
COMMAND="$1"
HOST="${2:-$(hostname)}" # fallback to current host
HOST="${HOST%.lan}" # remove .lan suffix if needed
shift 2

# Base args for nh
NH_ARGS=(
    "--hostname=$HOST"
    "--out-link=$ROOT_DIR/.gc/$HOST"
)

# Add required flags for remote deploy
if [[ "$HOST" != "$(hostname)" ]]; then
    NH_ARGS+=(
        "--target-host=root@$HOST.lan"
    )
fi

NH_ARGS+=(
    "$ROOT_DIR#"
)

# Create the GC roots dir
[ -d "$ROOT_DIR/.gc" ] || mkdir "$ROOT_DIR/.gc" >/dev/null

# Run nh
IFS=' ' echo "$ nh os $COMMAND ${NH_ARGS[*]} $*"
exec nh os "$COMMAND" "${NH_ARGS[@]}" "$@"
