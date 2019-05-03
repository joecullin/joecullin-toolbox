#!/usr/bin/perl --

# Scan apache logs on a few servers.
# To use:
# 1. Update the pattern.
# 2. Update the log file source. Search for path_to_logs below.

use strict;

my $server_list_file = "removed-for-sharing-on-github";
open (my $server_list_fh, '<', $server_list_file) or die("Can't open server list $server_list_file: $!");
my @servers = map {$_ =~ s/\s//g; $_} <$server_list_fh>;
close $server_list_fh;

my %server_nicknames = ();
for my $server (@servers)
{
	$server_nicknames{$server} = $1 if $server =~ /^([^.]*)/;
}

my $filter;
{
    my $pattern = 'Example string to search for. Change this.';

	$filter = qr{\Q$pattern\E};  # the \Q...\E takes care of all escaping.
}

print "searching for " . $filter . "\n";

# Some vars for parsing & sorting timestamps:
my %months; my $month; do { $months{$_} = sprintf("%02d", ++$month); } for (qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec));
my $timestamp_pattern = qr{^\[\w\w\w (\w\w\w) (\d\d) (\d\d)[:](\d\d)[:](\d\d)\.(\d\d\d\d\d\d) (\d\d\d\d)\]};

my @found_lines;
for my $server (@servers)
{
    # Use this for today's logs:
    my $cmd = qq{ssh $server 'cat /path_to_logs/www_access_log'};

    # Use this for gzipped and timestamped logs from a past date:
	# my $cmd = qq{ssh $server 'zcat /path_to_archived_logs/www_access_log-yymmdd*.gz'};

	my $log = qx{$cmd};
	print "$server\t$cmd\n\n";

	for (split /^/, $log)
	{
		chomp;
		my $line = $_;
		$line =~ /$filter/ or next;

		print "$line\n";

		my $time = ($line =~ /$timestamp_pattern/) ? join('', $7, $months{$1}, $2, $3, $4, $5, $6) : 0;
		push @found_lines, {
			'time' => $time,
			'server' => $server,
			'line' => $line,
		};
	}
}

print "Done. Found " . @found_lines . " lines\n";

