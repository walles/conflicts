# Git conflict resolution experiments

Run `./show-original-change.sh` on a git repo with conflicts to display your
original change that is causing a conflict.

## Testing

Run `./test-show-original-change.sh` on a git repo with conflicts to test the
`show-original-change.sh` on various forms of conflicts.

# TODO
* Add test for cherry picking conflicts
* Add test for edit-delete conflict
* Test a conflict in a file with spaces in its name
* Add test for when a new file is added in both branches, but with different
  contents

## DONE
* Add test for delete-edit conflict
