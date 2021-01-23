#!/bin/bash

set -euo pipefail

WORKDIR=/tmp/difftest
rm -rf $WORKDIR
mkdir -p $WORKDIR

cd $WORKDIR
git init

cat > names.txt << EOF
Adam
David
EOF
git add names.txt
git commit -m 'Initial commit'

cat > names.txt << EOF
Adam
Bertil
David
EOF
git add names.txt
git commit -m 'Add Bertil'

#git checkout HEAD^^
git checkout HEAD^
git checkout -b caesar-branch

date >> unrelated1.txt
git add unrelated1.txt
git commit -m "first unrelated change on caesar-branch"

cat > names.txt << EOF
Adam
Caesar
David
EOF
git add names.txt
git commit -m 'Add Caesar'

date >> unrelated2.txt
git add unrelated2.txt
git commit -m "second unrelated change on caesar-branch"

git rebase master || true

MYSHA=$(cat "$(git rev-parse --show-toplevel)"/.git/rebase-apply/original-commit)
git show "$MYSHA" > /tmp/mydiff.txt

watch --errexit "git diff HEAD > /tmp/currentdiff.txt && (diff -y /tmp/mydiff.txt /tmp/currentdiff.txt || true)"
