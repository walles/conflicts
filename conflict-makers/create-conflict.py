#!/usr/bin/env python3

"""
create-conflict.py cherrypick edit-delete /tmp/apa
"""

import os
import sys
import shutil
import tempfile
import subprocess


GREEN = "\x1b[32m"
PURPLE = "\x1b[35m"
BOLDWHITE = "\x1b[1;97m"
YELLOW = "\x1b[93m"
GREY = "\x1b[37m"
NORMAL = "\x1b[m"


def git(*args: str):
    branch = (
        subprocess.run(["git", "branch", "--show-current"], capture_output=True)
        .stdout.decode()
        .strip()
    )
    print(f"\n({PURPLE}{branch}{NORMAL}) $ {BOLDWHITE}git{NORMAL}{GREY}", end="")
    for arg in args:
        if " " in arg:
            print(f' {YELLOW}"{arg}"{GREY}', end="")
        else:
            print(f" {arg}", end="")
    print(NORMAL)
    subprocess.run(["git"] + list(args), check=True)


def create_conflict(conflict_operation: str, conflict_type: str) -> str:
    print("")
    print("")
    print(f"## {GREEN}{conflict_operation}-{conflict_type}{NORMAL}")
    conflict_dir = tempfile.mkdtemp(prefix=f"{conflict_operation}-{conflict_type}.")
    os.chdir(conflict_dir)

    # Set up initial state
    git("init", "-b", "main")
    open("file.txt", "w").write("Initial change\n")
    git("add", "file.txt")
    git("commit", "-m", "NO: Initial commit")

    if conflict_operation in ("merge", "cherrypick", "rebase"):
        # Set up my conflicting change on another branch...
        git("checkout", "-b", "branch")

        if conflict_operation == "merge":
            open("unrelated1.txt", "w").write("NO: Unrelated1\n")
            git("add", "unrelated1.txt")
            git("commit", "-m", "NO: unrelated1.txt")

        if conflict_type in ["edit-edit", "edit-delete"]:
            open("file.txt", "a").write("YES: My conflicting change\n")
            git("commit", "-a", "-m", "YES: My conflicting change")
        elif conflict_type == "delete-edit":
            git("rm", "file.txt")
            git("commit", "-m", "YES: My conflicting delete")
        elif conflict_type == "add-add":
            open("new-file.txt", "w").write("YES: My conflicting new file\n")
            git("add", "new-file.txt")
            git("commit", "-a", "-m", "YES: My conflicting new file")
        else:
            assert False

        if conflict_operation == "merge":
            open("unrelated2.txt", "w").write("NO: Unrelated1\n")
            git("add", "unrelated2.txt")
            git("commit", "-m", "NO: unrelated2.txt")

        # Set up the other change on main
        git("checkout", "main")
        if conflict_type in ["edit-edit", "delete-edit"]:
            open("file.txt", "a").write("NO: Their conflicting change\n")
            git("commit", "-a", "-m", "NO: Their conflicting change")
        elif conflict_type == "edit-delete":
            git("rm", "file.txt")
            git("commit", "-m", "NO: Their conflicting delete")
        elif conflict_type == "add-add":
            open("new-file.txt", "w").write("NO: Their conflicting new file\n")
            git("add", "new-file.txt")
            git("commit", "-a", "-m", "NO: Their conflicting new file")
        else:
            assert False

        # ... then create the conflict
        if conflict_operation == "merge":
            assert subprocess.run(["git", "merge", "--no-ff", "branch"]).returncode != 0
        elif conflict_operation == "rebase":
            git("checkout", "branch")
            assert subprocess.run(["git", "rebase", "main"]).returncode != 0
        elif conflict_operation == "cherrypick":
            assert subprocess.run(["git", "cherry-pick", "branch"]).returncode != 0
        else:
            assert False
    elif conflict_operation == "stash":
        # Create my stash
        if conflict_type in ["edit-edit", "delete-edit"]:
            open("file.txt", "a").write("YES: My conflicting change\n")
        elif conflict_type == "edit-delete":
            os.remove("file.txt")
        elif conflict_type == "add-add":
            open("new-file.txt", "w").write("YES: My conflicting new file\n")
            git("add", "new-file.txt")
        else:
            assert False
        git("stash")

        # Create and commit a conflicting change
        if conflict_type in ["edit-edit", "edit-delete"]:
            open("file.txt", "a").write("NO: Their conflicting change\n")
            git("add", "file.txt")
        elif conflict_type == "delete-edit":
            git("rm", "file.txt")
        elif conflict_type == "add-add":
            open("new-file.txt", "w").write("NO: Their conflicting new file\n")
            git("add", "new-file.txt")
        else:
            assert False
        git("commit", "-m", "NO: Their conflicting change")

        assert subprocess.run(["git", "stash", "pop"]).returncode != 0
    else:
        assert False

    return conflict_dir


for conflict_type in ("edit-edit", "edit-delete", "delete-edit", "add-add"):
    for conflict_operation in ("merge", "cherrypick", "rebase", "stash"):
        conflict_dir = create_conflict(conflict_operation, conflict_type)

        # FIXME: Verify show-original-change.sh can show the original change in
        # conflict_dir

        shutil.rmtree(conflict_dir)
