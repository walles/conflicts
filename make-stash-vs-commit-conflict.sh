#!/bin/bash

set -euo pipefail

if [ -z "${1+x}" ] || [ -e "$1" ] ; then
    echo "ERROR: Syntax: $0 <destination>"
    echo
    echo 'Directory destination will be created, and must not exist when invoking this script.'
    exit 1
fi

WORKDIR="$1"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"

cd "$WORKDIR"

# YES means that the text should be shown by show-my-original-change.sh, NO
# means that it should not.

# Create initial commit
git init -b main
echo "Initial change" > file.txt
git add file.txt
git commit -m "NO: Initial commit"

# Stash a change
git checkout -b branch
echo "YES: My change" >> file.txt
git stash

# Make another change in main branch
echo "NO: Committed change" >> file.txt
git commit -a -m "NO: Committed change"

# Create stash conflict. The && exit 1 is because we require this to fail,
# otherwise we didn't get ourselves the conflict we are after.
git stash pop && exit 1

echo "OK: Stash-vs-commit conflict created in $WORKDIR"
