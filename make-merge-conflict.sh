#!/bin/bash

set -euo pipefail

if [ -z "${1+x}" ] || [ -e "$1" ] ; then
    echo 'ERROR: Syntax: make-merge-conflict.sh <destination>'
    echo
    echo 'Directory destination will be created, and must not exist when invoking this script.'
    exit 1
fi

WORKDIR="$1"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"

cd "$WORKDIR"

# Create initial commit
git init -b main
echo "Initial change" > file.txt
git add file.txt
git commit -m "Initial commit"

# Make another branch with a branch specific change in it
git checkout -b branch
echo "Branch change" >> file.txt
git commit -a -m "Branch change"

# Make another change in main branch
git checkout main
echo "Main change" >> file.txt
git commit -a -m "Main change"

# Create merge conflict
git checkout branch
# The && exit 1 is because we require this to fail, otherwise we didn't get
# ourselves the conflict we are after.
git merge --no-ff main && exit 1

echo
echo "SUCCESS: Merge conflict created in $WORKDIR"
