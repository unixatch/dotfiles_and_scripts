#!/usr/bin/env bash
# shellcheck disable=2086

# NOTE: This script runs automatically inside the .vimrc.
#       If you want to run it, use it inside a subshell.
[[ ! -e .git/ ]] && exit 1

# Show a staged file or more
[[ -n ${ git diff --shortstat --staged; } ]] && {
    git diff --minimal --staged | delta --paging always
    exit
}
# OR show the latest commit
git show
exit

