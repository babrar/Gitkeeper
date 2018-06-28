#!/bin/bash
# Set up hook templates to set up git hooks
# All future repos created locally will automatically get the hooks
# Re-run this script to download new hook templates when they become available
# Replace remote_origin with webiste name (i.e. bitbucket or github)
# To make the script use HTTPS, run as $ ./init_repo.sh <your remote_origin password>
# To make the script use SSH, run as $ ./init_repo.sh

# Check for username
USERNAME=`git config --global remote_origin.username`
if [ $? -ne 0 ]; then
    echo "remote_origin username is not set.  Please run the following command to set it:"
    echo "  git config --global remote_origin.username <your remote_origin username>"
    exit 1
fi
echo "Got remote_origin user name $USERNAME"

# Check for usage mode (HTTPS or SSH)
#follow_SSH=0
PASSWORD=""
SSH_fail=0
follow_HTTPS=0
use_winpty=0
if [ $# -eq 1 ]; then
  follow_HTTPS=1
  if [ $1 = "--winpty" ];then
    # check if user inputted password or meant to use --winpty
    use_winpty=1
    echo "Using HTTPS to pull scripts from remote_origin"
    echo "Using winpty option. You will now be requiring authentication for each download"
  else
    PASSWORD=$1
    echo "Using HTTPS to pull scripts from remote_origin"
  fi
elif [ $# -eq 0 ]; then
  # Check for SSH compatibility first
  SSHSTAT=`ssh -T git@remote_origin.org`
  if [ $? -eq 0 ]; then
    echo "Using SSH to pull scripts from remote_origin"
    #follow_SSH=1
  else
    echo "$SSHSTAT"
    echo "SSH to remote_origin failed. Switching to HTTPS version"
    echo "You will now be requiring authentication for each download"
    SSH_fail=1
    follow_HTTPS=1
    #exit 1
  fi
else 
  echo "Usage (HTTPS): $0 <remote_origin password>"
  echo "OR"
  echo "Usage (SSH): $0"
  echo "OR"
  echo "Usage (HTTPS on minTTY): $0 --winpty" 
  exit 1
fi

# Create local template dir in case its not already there
mkdir ~/.git_template
mkdir ~/.git_template/hooks

# Halt on first error
set -e
#set -x

# set link for pre-commit hook download
  build_support_url="https://raw.githubusercontent.com/babrar/build_support_scripts/master"


# to notify --winpty users of files remaining to download 
no_of_files=4
# Download templates from remote_origin to home dir
if [ $follow_HTTPS -eq 1 ] && [ $SSH_fail -eq 0 ]; then 
    if [ $use_winpty -eq 0 ]; then
      # Download templates using HTTPS
      echo "Downloading pre-commit.pl hook (1/$no_of_files)"
      curl -u $USERNAME:$PASSWORD --fail --show-error --silent --output ~/.git_template/hooks/pre-commit $build_support_url/pre-commit.pl
      echo "Downloading prepare-commit-msg.py hook (2/$no_of_files)"
      curl -u $USERNAME:$PASSWORD --fail --show-error --silent --output ~/.git_template/hooks/prepare-commit-msg $build_support_url/prepare-commit-msg.py
      echo "Downloading commit-msg.py hook (3/$no_of_files)"
      curl -u $USERNAME:$PASSWORD --fail --show-error --silent --output ~/.git_template/hooks/commit-msg $build_support_url/commit-msg.py
      # Also download the customer list used by the pre-commit hook
      echo "Downloading customer list (4/$no_of_files)"
      curl -u $USERNAME:$PASSWORD --fail --show-error --silent --output ~/.git_template/customer_list.txt $build_support_url/customer_list.txt
    else 
      # Download templates using HTTPS with winpty option on minTTY terminal
      echo "Downloading pre-commit.pl hook (1/$no_of_files)"
      winpty curl -u $USERNAME --fail --show-error --silent --output ~/.git_template/hooks/pre-commit $build_support_url/pre-commit.pl
      echo "Downloading prepare-commit-msg.py hook (2/$no_of_files)"
      winpty curl -u $USERNAME --fail --show-error --silent --output ~/.git_template/hooks/prepare-commit-msg $build_support_url/prepare-commit-msg.py
      echo "Downloading commit-msg.py hook (3/$no_of_files)"
      winpty curl -u $USERNAME --fail --show-error --silent --output ~/.git_template/hooks/commit-msg $build_support_url/commit-msg.py
      # Also download the customer list used by the pre-commit hook
      echo "Downloading customer list (4/$no_of_files)"
      winpty curl -u $USERNAME --fail --show-error --silent --output ~/.git_template/customer_list.txt $build_support_url/customer_list.txt
    fi
elif [ $follow_HTTPS -eq 1 ] && [ $SSH_fail -eq 1 ]; then
    # Download templates using HTTPS requiring authentication for each download
    echo "If this command appears to hang (in SourceTree), try running init_repo.sh with the --winpty option."
    echo "Downloading pre-commit.pl hook (1/$no_of_files)"
    curl -u $USERNAME --fail --show-error --silent --output ~/.git_template/hooks/pre-commit $build_support_url/pre-commit.pl
    echo "Downloading prepare-commit-msg.py hook (2/$no_of_files)"
    curl -u $USERNAME --fail --show-error --silent --output ~/.git_template/hooks/prepare-commit-msg $build_support_url/prepare-commit-msg.py
    echo "Downloading commit-msg.py hook (3/$no_of_files)"
    curl -u $USERNAME --fail --show-error --silent --output ~/.git_template/hooks/commit-msg $build_support_url/commit-msg.py
    # Also download the customer list used by the pre-commit hook
    echo "Downloading customer list (4/$no_of_files)"
    curl -u $USERNAME --fail --show-error --silent --output ~/.git_template/customer_list.txt $build_support_url/customer_list.txt
else  
    # Download templates using SSH
    echo "Downloading pre-commit.pl hook (1/$no_of_files)"
    git archive --remote=git@remote_origin.org:remote/build_support_scripts.git HEAD pre-commit.pl | tar -xO > ~/.git_template/hooks/pre-commit
    echo "Downloading prepare-commit-msg.py hook (2/$no_of_files)"
    git archive --remote=git@remote_origin.org:remote/build_support_scripts.git HEAD prepare-commit-msg.py | tar -xO > ~/.git_template/hooks/prepare-commit-msg
    echo "Downloading commit-msg.py hook (3/$no_of_files)"
    git archive --remote=git@remote_origin.org:remote/build_support_scripts.git HEAD commit-msg.py | tar -xO > ~/.git_template/hooks/commit-msg
    # Also download the customer list used by the pre-commit hook
    echo "Downloading customer list (4/$no_of_files)"
    git archive --remote=git@remote_origin.org:remote/build_support_scripts.git HEAD customer_list.txt | tar -xO > ~/.git_template/customer_list.txt
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
