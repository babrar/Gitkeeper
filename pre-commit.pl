#!/usr/bin/perl
# The hook should exit with non-zero status after issuing an appropriate 
# message if it wants to stop the commit.
#   ==> Redirect stdout to stderr
# Replace remote_origin with webiste name (i.e. bitbucket or github)
# It is run with the working dir set to the top level of the working tree
#  http://longair.net/blog/2011/04/09/missing-git-hooks-documentation/
#
# ? How do hook variables work ? e.g. hooks.allownonascii
#
# Hard errors and Warnings are categorized separately. 

use strict;
use warnings;

#  exit flags
my $is_binary = 0;
my $over_MAX_SIZE = 0; 
my $filemode_change = 0;
my $tabs_exist = 0;
my $curl_fail = 0;

my $mintty = 0;
my $SSH =1;

# Check if SSH to remote_origin can be done 
my $ssh_stat=`ssh -T git\@remote_origin.org`;
if ($? != 0)
{
  $SSH = 0;
  print STDERR "$ssh_stat\n";
  print STDERR "SSH to remote_origin failed. Using HTTPS authentication\n";
}

my $file;
my $MAX_SIZE = 100000; # Limit files to 100KB

# Go through all modified files that will be commited  
#  --diff-filter is needed to exclude removed files from the check
#  ACM is Added, Copied and Modified
my @file_list =  `git diff --cached --name-only --diff-filter=ACM`;
#print @file_list;

#----------------------------------------------------------------------------------------
# Hard Errors - All tests MUST pass before commit
#----------------------------------------------------------------------------------------

# Download customer name list to local folder if we don't already have a recent copy
# Check that it is no more than 1 day old, otherwise download a fresh copy
if ((! -e ".git/customer_list.txt") || (-M ".git/customer_list.txt" > 1))
{
  # Get username 
  my $USERNAME = `git config --global remote_origin.username`;
  if ($? != 0) 
  {
    print STDERR "remote_origin username is not set.  Please run the following command to set it:\n";
    print STDERR "  git config --global remote_origin.username <your remote_origin username>\n";
    exit 1;
  }
  chomp($USERNAME);
  
  # Check if MinTTY environment variable is set 
  my $env_var = $ENV{'minTTY'};
  if ( length($env_var) )
  {
    $mintty = 1;
  }
  
  # Download customer_list.txt using SSH authentication (if fails, use curl)
  if($SSH)
  {
    system("git archive --remote=git\@remote_origin.org:remote/build_support_scripts.git HEAD customer_list.txt | tar -xO > .git/customer_list.txt");
    if ($? != 0)
    {
      print STDERR "SSH failed to download customer_list.txt from remote_origin";
      exit 1;
    }
  }
  else # use Curl
  {
    if (!$mintty)
    {
      system("curl -u $USERNAME --show-error --silent --fail --connect-timeout 30 --max-time 40 --output .git/customer_list.txt https://remote_origin.org/remote/build_support_scripts/file");
      if ($? != 0)
      {
        $curl_fail =1;
      }
    }
    else # use winpty on Curl for minTTY terminals
    {
      system("winpty curl -u $USERNAME --show-error --silent --fail --connect-timeout 30 --max-time 40 --output .git/customer_list.txt https://remote_origin.org/remote/build_support_scripts/file");
      if ($? != 0)
      {
        $curl_fail =1;
      }
    }
  }
  
  # Exit in case of errors
  if ($curl_fail) 
  {
    print "curl failed to download customer_list.txt: $!\n";
    if (-e ".git/customer_list.txt")
    {
      print "Using existing copy\n";
    }
    else 
    {
      exit 1;
    }
  }
  else
  {
    #print "Curl download completed successfully\n";
  }
}

# Check for tabs
foreach $file (@file_list)
{
  chomp($file);
  
  # Only check source files for tabs
  if ( $file =~ /\.c$|\.cpp$|\.h$|\.hpp$|\.py$/i )
  {
    my $line;
    my @lines;
    my $line_num = 0; 
      
    open(FILE, $file) or die "Can't open `$file'}': $!";
    @lines = <FILE>;
    close FILE;
    foreach  $line (@lines) 
    {
      $line_num++;
      chomp($line);
      if ( $line =~ /\t/i ) 
      {
        $tabs_exist = 1;
        print STDERR "$file \@$line_num: $line\n";
      }
    }
  }
}
# If no tabs found, allow operation to proceed.
if ($tabs_exist)
{
  print STDERR "ERROR: Tabs found in files listed above. Commit Aborted.\n";
  print STDERR "Please replace the tabs with spaces.\n";
  exit 1;
}

#----------------------------------------------------------------------------------------
# Warnings - only to show if no errors encountered above in Hard Errors
#----------------------------------------------------------------------------------------

# Only check binary and file size when files are added otherwise users
# get error every time they modify they file.   This has the dissadvantage
# of not catching if a file grows too large after the initial commit
#
# Get list of added files only (i.e. new files)
my @new_file_list =  `git diff --cached --name-only --diff-filter=A`;
foreach $file (@new_file_list)
{
  chomp($file);
  
  # Check if file is binary
  if (-B $file)
  {
    print STDERR "WARNING: $file is binary.\n";
    print STDERR "Please check with repo owner before committing binary files.\n";
    print STDERR "To bypass this warning re-run your commit with the '--no-verify' option\n";
    $is_binary = 1;
    #exit 1;
  }

  # Check if file is very large
  if (-s $file > $MAX_SIZE)
  {
    print STDERR "WARNING: $file is greater than $MAX_SIZE bytes.\n";
    print STDERR "Please check with repo owner before committing very large files.\n";
    #print STDERR "To bypass this warning re-run your commit with the '--no-verify' option\n";
    $over_MAX_SIZE = 1;
    #exit 1;
  }
}

# Go through all the modified files
# Check for file mode changes.
my @file_list_M =  `git diff --cached --name-only --diff-filter=M`;
foreach $file (@file_list_M)
{
  chomp ($file);
  
  my $line;

  # obtain changes for current file
  my @file_diff = `git diff --cached $file`;
  
  foreach $line (@file_diff)
  { 
    # move to next file if chunk region is entered. Quick exit if old mode is not expected.
    if ($line =~ /^@@/)
    {
      #print "Skipping all edit lines\n";
      last;
    }
    
    # the term 'old mode' only appears during a change in file mode
    # thus, it can be used to detect a change in file mode
    # any text in the chunk region is indented by one space
    # so the 'real' old mode will be the first word of a new line.
    if ($line =~ /^old mode/i)
    {
      print STDERR "WARNING: File mode change detected in $file\n";
      print STDERR "Use git diff HEAD $file to view the change\n\n";
      $filemode_change = 1; # filemode-change detected in at least one file
      
      #print "Moving to next file";
      last;
    }
  }
}
if ($is_binary or $over_MAX_SIZE or $filemode_change)
{
  print STDERR "Commit Aborted. To bypass this warning re-run your commit with the '--no-verify' option\n";
  exit 1;
}
else
{
  exit 0;
}