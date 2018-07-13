#!/usr/bin/perl
# The hook should exit with non-zero status after issuing an appropriate 
# message if it wants to stop the commit.
#   ==> Redirect stdout to stderr
# It is run with the working dir set to the top level of the working tree
#  http://longair.net/blog/2011/04/09/missing-git-hooks-documentation/
#
# ? How do hook variables work ? e.g. hooks.allownonascii
#
# Hard errors and Warnings are categorized separately. 

use Cwd;
use strict;
use warnings;

#  exit flags
my $is_binary = 0;
my $over_MAX_SIZE = 0; 
my $filemode_change = 0;
my $tabs_exist = 0;
# my $curl_fail = 0;

my $mintty = 0;
my $SSH =1;
my $dir = getcwd();
=pod
# Check if SSH to github can be done 
my $ssh_stat=`ssh -T git\@github.com`;
if ($? != 1) # for gitghub, successful SSH returns 1
{
  $SSH = 0;
  print STDERR "$ssh_stat\n";
  print STDERR "Warning: SSH to github failed. Using HTTPS authentication\n";
}
=cut
my $MAX_SIZE = 1000000; # Limit files to 1000KB

my $file;
# Go through all modified files that will be commited  
#  --diff-filter is needed to exclude removed files from the check
#  ACM is Added, Copied and Modified
my @file_list =  `git diff --cached --name-only --diff-filter=ACM`;
#print @file_list;

#----------------------------------------------------------------------------------------
# Hard Errors - All tests MUST pass before commit
#----------------------------------------------------------------------------------------

=pod  
  # Check if MinTTY environment variable is set 
  # Windows user can set a minTTY var just for using MINGW32 terminal
  my $env_var = $ENV{'minTTY'}; 
  if ( length($env_var) )
  {
    $mintty = 1;
  }
=cut
 
# Check for tabs
foreach $file (@file_list)
{
  chomp($file);
  
  # Only check source files for tabs
  if ( $file =~ /\.c$|\.cpp$|\.h$|\.hpp$|\.js$|\.go$|\.pl$|\.sh$|\.java$|\.py$/i )
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
# Otherwise...
if ($tabs_exist)
{
  print STDERR "ERROR: Tabs found in files listed above. Commit Aborted.\n";
  print STDERR "Please replace the tabs with spaces.\n";
  print STDERR "To force the commit, bypass this error by re-running your commit with the '--no-verify' option\n";
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
  print STDERR "Commit Aborted \n";
  print STDERR "To force the commit, bypass this warning by re-running your commit with the '--no-verify' option\n";
  exit 1;
}
else
{
  exit 0;
}