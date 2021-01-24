#!/bin/bash

set -euo pipefail

test-conflict() {
    TYPE="$1"

    echo "============ Setting up a $TYPE conflict"
    WORKDIR="$(mktemp -d)"
    rmdir "$WORKDIR"
    ./make-"$TYPE"-conflict.sh "$WORKDIR" >& /dev/null
    echo "============ Testing a $TYPE conflict"
    ./show-my-original-change.sh "$WORKDIR" | cat
    ./show-my-original-change.sh "$WORKDIR" | grep "YES: " > /dev/null
    ./show-my-original-change.sh "$WORKDIR" | grep "NO: " > /dev/null && exit 1
    rm -rf "$WORKDIR"
    echo "============ Testing a $TYPE conflict: PASS"
}

test-conflict rebase
test-conflict merge
test-conflict stash-vs-commit
