#!/usr/bin/env bash
echo Testing server $1
nix-build -A $1 --no-out-link --show-trace
# rm result*