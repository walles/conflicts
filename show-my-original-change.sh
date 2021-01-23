#!/bin/bash

set -euo pipefail

if [ -z "${1+x}" ] || [ ! -d "$1" ] ; then
    echo "ERROR: Syntax: $0 <dir-with-conflict>"
    echo
    echo 'Directory dir-with-conflict will be examined for conflicts.'
    exit 1
fi

cd "$1"

if [ -f ".git/REBASE_HEAD" ] ; then
    git show "$(cat .git/REBASE_HEAD)"
    exit
fi

# FIXME: Add support for merge conflicts

# FIXME: Add support for stash-vs-commit conflicts

echo "ERROR: No conflict found"
echo
echo "Either $1 contains no conflict, or the conflict type is not supported by this script."
exit 1
