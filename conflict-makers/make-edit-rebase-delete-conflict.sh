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

# Make another branch with branch specific changes in it
git checkout -b branch

echo "hej" > somefile.txt
git add somefile.txt
git commit -m "NO: Unrelated"

echo "YES: My conflicting change" >> file.txt
git commit -a -m "YES: My conflicting change"

echo "nej" > someotherfile.txt
git add someotherfile.txt
git commit -m "NO: Unrelated2"

# Make another change in main branch
git checkout main
git rm file.txt
git commit -m "NO: Delete in main"

# Create rebase conflict
git checkout branch
# The && exit 1 is because we require this to fail, otherwise we didn't get
# ourselves the conflict we are after.
git rebase main && exit 1

echo "OK: Rebase conflict created in $WORKDIR"
