#!/bin/bash 

# dirname removes suffix starting with '/' from PWD
# get path one level up dir
parentdir="$(dirname "$(pwd)")"
cp initrepo.sh $parentdir
