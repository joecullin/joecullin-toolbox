#!/usr/bin/perl --

# Copy a set of tables from one mysql server to another.

use strict;
use POSIX; 

################################################

my $sourceServer = 'example1';
my $sourceDb = 'db_schema';

my $destServer = 'example2';
my $destDb = 'db_schema';

my @tables = qw(
table_1
table_2
);

my $where = '';  #  '--where "id > 2435509"';

################################################

my $hosts = {
  'example1' => {'host' => 'example', 'user' => 'example', 'pass' => 'example'},
  'example2' => {'host' => 'example', 'user' => 'example', 'pass' => 'example'},
};
my $sourceHost = $hosts->{$sourceServer}->{'host'};
my $sourceUser = $hosts->{$sourceServer}->{'user'};
my $sourcePass = $hosts->{$sourceServer}->{'pass'};
my $destHost = $hosts->{$destServer}->{'host'};
my $destUser = $hosts->{$destServer}->{'user'};
my $destPass = $hosts->{$destServer}->{'pass'};

my $tableCount = 0;
my $totalTables = scalar(@tables);
writeLog("Copying $totalTables tables from $sourceHost/$sourceDb to $destHost/$destDb.");
for my $table (@tables)
{
	$tableCount++;
	writeLog("Copying table ($tableCount of $totalTables): $table");
	my $tmpFile = "/tmp/joe_transfer_temp.txt";

	# (Using a temp file is nice when one end is much slower than the other. It doesn't lock up both sides the whole time.)

	my $startTime = time;
	my $cmd = "mysqldump --verbose --opt --quick --single-transaction --host=$sourceHost -u$sourceUser -p$sourcePass $sourceDb $table $where > $tmpFile";
	writeLog("dumping table: $cmd");
	system($cmd);

	$cmd = "mysql --host=$destHost -u$destUser -p$destPass $destDb < $tmpFile";
	writeLog("loading table: $cmd");
	system($cmd);

	unlink($tmpFile);

	my $elapsed = time - $startTime; my ($seconds, $minutes) = ($elapsed % 60, int($elapsed / 60));
	writeLog("Finished $table. $minutes minutes, $seconds seconds");

	# give the system a little rest in between copies of big tables.
	if ($elapsed > 10 && $tableCount != $totalTables)
	{
		my $sleepTime = ceil($elapsed/10);
		writeLog("resting for $sleepTime seconds after such a big table...");
		sleep($sleepTime);
	}
}

sub writeLog
{
	my $message = shift;
	my $timestamp = strftime("%F %T", localtime); 
	print "$timestamp\t$message\n";
}

