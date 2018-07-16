#!/bin/bash 

# dirname removes suffix starting with '/' from PWD
# get path one level up dir
repoRoot="$(dirname "$(pwd)")"
rm -f $repoRoot/.git/hooks/pre-commit
rm -rf ~/.git_template
rm -f $repoRoot/initrepo.sh

cd $repoRoot && git init

echo "Hooks uninstalled. Repository Reinitialized."
echo "You can now delete the Gitook directory from your repository."
