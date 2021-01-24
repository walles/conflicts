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

# Make another branch with a branch specific change in it
git checkout -b branch
echo "YES: My change" >> file.txt
git commit -a -m "YES: My change"

# Make another change in main branch
git checkout main
echo "NO: Main change" >> file.txt
git commit -a -m "NO: Main change"

# Create rebase conflict
git checkout branch
# The && exit 1 is because we require this to fail, otherwise we didn't get
# ourselves the conflict we are after.
git rebase main && exit 1

echo "OK: Rebase conflict created in $WORKDIR"
