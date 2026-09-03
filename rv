#!/bin/sh

# How I review PRs (and sometimes even my own big changes).
# - file summary - paste into scratch vi so I can get an overview and make notes
# - full diff

# TODO:
#  add a blank line between packages/apps in summary.

COMMIT_ID="$1"
#echo "COMMIT_ID: '$COMMIT_ID'"
git diff -w $COMMIT_ID --name-status | perl -p -e 's/^/- /' | pbcopy
git diff -w $COMMIT_ID
