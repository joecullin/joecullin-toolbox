#!/usr/bin/perl --

#
# I got tired of typing "ls -halt ... | more"
# Now I just type "sl ..."
#

# Quote each argument.
# When you run "sl *a*", the shell interprets the "*a*" and passes a list of files
# in @ARGV.  I noticed that things broke on a file named "#blah#" (like emacs creates),
# and quoting each argument fixed that.
map {$_ = "\"$_\""} @ARGV;

my $hasLess = 1 unless ($^O eq 'aix');
# (-E Causes less to automatically exit  the  first  time  it reaches end-of-file.)
# (-X disables the annoying "clear screen" on exit.)
my $pager = $hasLess ? 'less -E -X' : 'more';

# put the command together
$command = "ls -halt @ARGV | $pager";

# debugging
# print "$command\n";


# perldoc -f exec says you might want to change this when using exec
$| = 1;

# run the command and exit
exec $command;
