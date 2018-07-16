#!/bin/bash
# Set up hook templates to set up git hooks
# All future repos created locally will automatically get the hooks
# Re-run this script to download new hook templates when they become available
# Running 'git init' will call templates from git_template dir
# and set those as the hooks in the .git dir of the initialized repo

# general run log
timestamp=`date`
echo "$timestamp" >> Gitook/log/run.log 

# Create local template dir in case its not already there
echo "Setting up inital .git_template dir. Will be skipped if already exits"
mkdir ~/.git_template 2>> Gitook/log/run.log
mkdir ~/.git_template/hooks 2>> Gitook/log/run.log

# Halt on first error
#set -e
#set -x

# set link for hook download
  hook_url="https://raw.githubusercontent.com/babrar/gitook/master"

# download pre-commit from Gitook repo. If fails, use local copy
curl --fail --silent --output ~/.git_template/hooks/pre-commit $hook_url/pre-commit.pl

if [ $? -ne 0 ]; then
    echo "$timestamp" >> Gitook/log/error.log
    curl --fail --silent --show-error --output ~/.git_template/hooks/pre-commit $hook_url/pre-commit.pl 2>> Gitook/log/error.log
    # try to find a workaround if possible (look into tee command)
    curl --fail --silent --show-error --output ~/.git_template/hooks/pre-commit $hook_url/pre-commit.pl 2>> Gitook/log/run.log
    echo "Warning: (CURL) Unable to download hooks from Gitook. Using local copy..."
    # log errors to error.log
    #echo "$curlStat" >> Gitook/log/error.log
    # moving hooks manually
    cp Gitook/pre-commit.pl ~/.git_template/hooks/pre-commit
fi

# Force the execute bit to be set
chmod a+x  ~/.git_template/hooks/*

# Configure Git templates
git config --global init.templatedir '~/.git_template'

# Configure release_notes.txt merge to always take ours
git config --global merge.ours.driver true

# Update the current repo by removing old hooks and running 'git init' in .git dir
rm -rf .git/hooks/*
git init

echo "Tip: To view the summary of this run, cd into Gitook dir and type 'make report'"
echo "OR, to view error log, cd into Gitook dir and type 'make error'"

echo "***You're all Set! To know what changes will be monitored in your repo,"
echo "view Specifications section on Gitook's GitHub repository.***"
