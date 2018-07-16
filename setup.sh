#!/bin/bash 


# dirname removes suffix starting with '/' from PWD
# get path one level up dir
parentdir="$(dirname "$(pwd)")"

# add Gitook/ and initrepo.sh to user's .gitignore
# if Gitook is run for the first time
if [ ! -f $parentdir/initrepo.sh ]; then
    echo "Gitook/" >> $parentdir/.gitignore
    echo "initrepo.sh" >> $parentdir/.gitignore
fi

# move initrepo.sh to repo root
cp initrepo.sh $parentdir


