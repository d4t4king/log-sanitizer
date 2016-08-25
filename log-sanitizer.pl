#!/usr/bin/perl -w

use strict;
use warnings;

use Term::ANSIColor;
use Data::Dumper;
use Getopt::Long qw/ :config no_ignore_case bundling /;

my ($help, $verbose, $ip, $mac, $email, $hex, $input, $output);
$verbose = 0;
GetOptions(
	'h|help'		=>	\$help,
	'v|verbose+'	=>	\$verbose,
	'i|input=s'		=>	\$input,
	'o|output=s'	=>	\$output,
	'ip:s'			=>	\$ip,
	'mac:s'			=>	\$mac,
	'email:s'		=>	\$email,
	'x|hex'			=>	\$hex
);

&usage() if ($help);

$ip		= 'all' if ((defined($ip)) and ($ip eq ''));
$mac 	= 'all' if ((defined($mac)) and ($mac eq ''));
$email	= 'all' if ((defined($email)) and ($email eq ''));

print colored("\$ip:\t $ip \n", "bold yellow")			if ((defined($ip)) and ($verbose));
print colored("\$mac:\t $mac \n", "bold yellow")		if ((defined($mac)) and ($verbose));
print colored("\$email:\t $email \n", "bold yellow")	if ((defined($email)) and ($verbose));

my $ip_rgx = qr/(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/;
my $mac_rgx = qr/(?:[0-9a-fA-F]{2}(:|-)){5}[0-9a-fA-F]{2}/;
my $mac_nc_rgx = qr/(?:[0-9a-fA-F]{2}(?:\:|-)){5}(?:\:|-)[0-9a-fA-F]{2}/;
my $TLDs = qr/(?:com|net|org|edu|us|co.uk|biz|info)/;
my $email_rgx = qr/[0-9a-zA-Z_.-]+\@(?:[0-9a-zA-Z-]+\.){1,3}$TLDs/;
my $content = "";
my %obfusips;

open IN, "<$input" or die colored("There was a peoblem opening the input file ($input): $! \n", "bold red");
while (<IN>) { $content .= $_; }
close IN or die colored("There was a problem closing the input file ($input): $! \n", "bold red");

if (defined($ip)) {
	if ($ip =~ /^all$/i) { 
			$content =~ s/$ip_rgx/x.x.x.x/xsg; 
	} elsif ($ip =~ /$ip_rgx/x) { $content =~ s/$ip/x.x.x.x/xsg; }
} 

if (defined($mac)) {
	if ($mac =~ /^all$/i) { $content =~ s/$mac_rgx/xx$1xx$1xx$1xx$1xx$1xx/xsg; } 
	elsif ($mac =~ /$mac_rgx/x) { $content =~ s/$mac/xx$1xx$1xx$1xx$1xx$1xx/xsg; }
}

if (defined($email)) {
	if ($email =~ /^all$/i) { $content =~ s/$email_rgx/xxx\@xxx.xxx/xsg; }
	elsif ($email =~ /$email_rgx/x) { $content =~ s/$email/xxx\@xxx.xxx/xsg; }
}

open OUT, ">$output" or die colored("There was a problem opening the output file ($output) for writing: $! \n", "bold red");
print OUT $content;
close OUT or die colored("There was a problem closing the output file ($output) after writing: $! \n", "bold red");

###############################################################################
# Subs
###############################################################################
sub usage {
	print <<END;

$0 [-hvx] [--ip] [--mac] [--email] [-i|--input] [-o|--output]

Where:

-h|--help				Displays this useful message, then exits.
-v|--verbose				Increases the level of output.  Use multiple times for more verbose output.
-i|--input <file>			Specifies the file to sanitize.
-o|--output <file>			Specifies the the file to save the sanitized output.
--ip <ip|all>				Specifies a specific IP to sanitize, or all.
--mac <mac|all>				Specifies a specific MAC address to sanitize, or all.
--email <email|all>			Specifies a specific email address to sanitize, or all.
-x|--hex				If specified, will attempt to look for hexadecimal IP addresses.  Otherwise ignored.

END

	exit 0;
}

sub obfusip {
	my $ip = shift(@_);

	my $lo = (split(/\./, $ip))[-1];
	my $r1 = int(rand(255));
	print colored("R1: $r1 \n", "bold yellow") if ($verbose);
	my $r2 = int(rand(255));
	print colored("R2: $r2 \n", "bold yellow") if ($verbose);
	
	$obfusip{$ip} = "10.$r1.$r2.$lo";
}
