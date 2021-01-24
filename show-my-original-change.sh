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

if [ -f ".git/REBASE_HEAD" ] ; then
    git show "$(cat .git/REBASE_HEAD)"
    exit
fi

if [ -f ".git/MERGE_HEAD" ] ; then
    git show "$(cat .git/MERGE_HEAD)"
    exit
fi

# We have a conflict, but it's neither a merge nor a rebase one, take our
# chances on "git stash pop".
git stash show -p
