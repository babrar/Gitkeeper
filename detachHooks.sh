#!/bin/bash 

# dirname removes suffix starting with '/' from PWD
# get path one level up dir
repoRoot="$(dirname "$(pwd)")"
rm -f $repoRoot/.git/hooks/pre-commit
rm -f ~/.git_template
