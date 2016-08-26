#!/usr/bin/perl -w

use strict;
use warnings;

use Term::ANSIColor;
use Data::Dumper;
use Getopt::Long qw/ :config no_ignore_case bundling /;

my ($help, $verbose, $cleanip, $cleanmac, $cleanmail, $cleanhex, $input, $output, $obfus);
$verbose = 0;
GetOptions(
	'h|help'		=>	\$help,
	'v|verbose+'	=>	\$verbose,
	'i|input=s'		=>	\$input,
	'o|output=s'	=>	\$output,
	'ip:s'			=>	\$cleanip,
	'mac:s'			=>	\$cleanmac,
	'email:s'		=>	\$cleanmail,
	'x|hex'			=>	\$cleanhex,
	'obfusips'		=>	\$obfus,
);

&usage() if ($help);

$cleanip		= 'all' if ((defined($cleanip)) and ($cleanip eq ''));
$cleanmac 	= 'all' if ((defined($cleanmac)) and ($cleanmac eq ''));
$cleanmail	= 'all' if ((defined($cleanmail)) and ($cleanmail eq ''));

print colored("\$cleanip:\t $cleanip \n", "bold yellow")			if ((defined($cleanip)) and ($verbose));
print colored("\$mac:\t $cleanmac \n", "bold yellow")		if ((defined($cleanmac)) and ($verbose));
print colored("\$email:\t $cleanmail \n", "bold yellow")	if ((defined($cleanmail)) and ($verbose));

my $ip_rgx = qr/(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/;
my $mac_rgx = qr/(?:[0-9a-fA-F]{2}(:|-)){5}[0-9a-fA-F]{2}/;
my $mac_nc_rgx = qr/(?:[0-9a-fA-F]{2}(?:\:|-)){5}(?:\:|-)[0-9a-fA-F]{2}/;
my $TLDs = qr/(?:com|net|org|edu|us|co.uk|biz|info)/;
my $email_rgx = qr/[0-9a-zA-Z_.-]+\@(?:[0-9a-zA-Z-]+\.){1,3}$TLDs/;
my $content = "";
my (%found_ips, %obfusips);

open IN, "<$input" or die colored("There was a peoblem opening the input file ($input): $! \n", "bold red");
while (my $line = <IN>) { 
	while ($line =~ /($ip_rgx)/g) {
		my $ip = $1;
		$found_ips{$ip}++;
		if ($obfus) { &obfusip($ip); }
	}
	$content .= $line; 
}
close IN or die colored("There was a problem closing the input file ($input): $! \n", "bold red");

print "Found ".scalar(keys(%found_ips))." total IPs. \n";
print "Obfuscated ".scalar(keys(%obfusips))." IPs. \n";
#print Dumper(\%obfusips);

if (defined($cleanip)) {
	if ($cleanip =~ /^all$/i) {
		foreach my $ip ( keys %found_ips ) {
			if ($obfus) { $content =~ s/$ip/$obfusips{$ip}/xsg; } 
			else { $content =~ s/$ip/d.e.a.d/xsg; }
		}
	} else {
		if ($obfus) { $content =~ s/$cleanip/$obfusips{$cleanip}/xsg; }
		else { $content =~ s/$cleanip/d.e.a.d/xsg; }
	}
}

if (defined($cleanmac)) {
	if ($cleanmac =~ /^all$/i) { $content =~ s/$mac_rgx/xx$1xx$1xx$1xx$1xx$1xx/xsg; } 
	elsif ($cleanmac =~ /$mac_rgx/x) { $content =~ s/$cleanmac/xx$1xx$1xx$1xx$1xx$1xx/xsg; }
}

if (defined($cleanmail)) {
	if ($cleanmail =~ /^all$/i) { $content =~ s/$email_rgx/xxx\@xxx.xxx/xsg; }
	elsif ($cleanmail =~ /$email_rgx/x) { $content =~ s/$cleanmail/xxx\@xxx.xxx/xsg; }
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
	
	$obfusips{$ip} = "10.$r1.$r2.$lo";
}
