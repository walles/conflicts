#!/bin/bash

set -euo pipefail

if [ -z "${1+x}" ] || [ ! -d "$1" ] ; then
    >&2 echo "ERROR: Syntax: $0 <dir-with-conflict>"
    >&2 echo
    >&2 echo 'Directory dir-with-conflict will be examined for conflicts.'
    exit 1
fi

cd "$1"

# See: https://github.com/desktop/desktop/issues/7831#issuecomment-503534419
if ! git status --porcelain=2 | grep -Eq '^u ' ; then
    >&2 echo "ERROR: No conflict detected, nothing to show"
    exit 1
fi

for CONFLICTING in $(git status --porcelain=2|grep -E '^u '|cut -d' ' -f11-) ; do
    BASE_FILE="$(mktemp)"
    # Source for the :1: and :3: syntax: https://stackoverflow.com/a/44754855/473672
    git show ":1:$CONFLICTING" > "$BASE_FILE"

    MY_FILE="$(mktemp)"
    git show ":3:$CONFLICTING" > "$MY_FILE"

    # "exit 1" if there was no difference, that wouldn't make any sense
    DIFF_FILE="$(mktemp)"
    diff -pub "$BASE_FILE" "$MY_FILE" > "$DIFF_FILE" && exit 1

    # Have the diff filenames match the repo ones
    < "$DIFF_FILE" sed "s@$BASE_FILE@$CONFLICTING@" | sed "s@$MY_FILE@$CONFLICTING@"

    rm "$BASE_FILE" "$MY_FILE" "$DIFF_FILE"
done
