#!/usr/bin/perl -w

use strict;
use warnings;

use Data::Dumper;
use Getopt::Long qw/ :config no_ignore_case bundling /;

my ($help, $verbose, $ip, $mac, $email, $hex, $input, $output);
$verbose = 0;
GetOptions(
	'h|help'		=>	\$help,
	'v|verbose+'	=>	\$verbose,
	'i|input=s'		=>	\$input,
	'o|output=s'	=>	\$output,
	'ip=s'			=>	\$ip,
	'mac=s'			=>	\$mac,
	'email=s'		=>	\$email,
	'x|hex'			=>	\$hex
);

&usage() if ($help);

my $ip_rgx = qr/(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}?(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/;

###############################################################################
# Subs
###############################################################################
sub usage {
	print <<END;

$0 [-hvx] [--ip] [--mac] [--email] [-i|--input] [-o|--output]

Where:

-h|--help				Displays this useful message, then exits.
-v|--verbose			Increases the level of output.  Use multiple times for more verbose output.
-i|--input <file>		Specifies the file to sanitize.
-o|--output <file>		Specifies the the file to save the sanitized output.
--ip <ip|all>			Specifies a specific IP to sanitize, or all.  Default is all.
--mac <mac|all>			Specifies a specific MAC address to sanitize, or all.  Default is all.
--email <email|all>		Specifies a specific email address to sanitize, or all.  Default is all.
-x|--hex				If specified, will attempt to look for hexadecimal IP addresses.  Otherwise ignored.

END

	exit 0;
}
