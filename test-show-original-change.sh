#!/bin/bash

set -euo pipefail

echo "============ Testing a rebase conflict"
WORKDIR="$(mktemp -d)"
rmdir "$WORKDIR"
./make-rebase-conflict.sh "$WORKDIR"
./show-my-original-change.sh "$WORKDIR" | grep "My change" > /dev/null
rm -rf "$WORKDIR"

echo
echo
echo "============ Testing a merge conflict"
WORKDIR="$(mktemp -d)"
rmdir "$WORKDIR"
./make-merge-conflict.sh "$WORKDIR"
./show-my-original-change.sh "$WORKDIR" | grep "My change" > /dev/null
rm -rf "$WORKDIR"

echo
echo
echo "============ Testing a stash conflict"
WORKDIR="$(mktemp -d)"
rmdir "$WORKDIR"
./make-stash-vs-commit-conflict.sh "$WORKDIR"
./show-my-original-change.sh "$WORKDIR" | grep "My change" > /dev/null
rm -rf "$WORKDIR"
