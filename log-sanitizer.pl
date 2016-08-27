#!/usr/bin/perl -w

use strict;
use warnings;

use Term::ANSIColor;
use Data::Dumper;
use Getopt::Long qw/ :config no_ignore_case bundling /;

my ($help, $verbose, $cleanip, $cleanmac, $cleanmail, $cleanhex, $input, $output, $smartip, $vendormac);
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
	'smartip'		=>	\$smartip,
	'vendormac'		=>	\$vendormac,
);

&usage() if ($help);

$cleanip		= 'all' if ((defined($cleanip)) and ($cleanip eq ''));
$cleanmac 	= 'all' if ((defined($cleanmac)) and ($cleanmac eq ''));
$cleanmail	= 'all' if ((defined($cleanmail)) and ($cleanmail eq ''));

die colored("The --smartip option only applies to IPv4 obfuscation. \n", "bold red") if (($smartip) and (!$cleanip));
die colored("The --vendormac option only applies to MAC addresses.  You must specify the --mac option. \n", "bold red") if (($vendormac) and (!$cleanmac));

print colored("\$cleanip:\t $cleanip \n", "bold yellow")			if ((defined($cleanip)) and ($verbose));
print colored("\$mac:\t $cleanmac \n", "bold yellow")		if ((defined($cleanmac)) and ($verbose));
print colored("\$email:\t $cleanmail \n", "bold yellow")	if ((defined($cleanmail)) and ($verbose));

my $ip_rgx = qr/(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/;
my $xBp = qr/[0-9a-fA-F]{2}/;			### heX Byte Pair (xBp)
### Precompiled regular expression are compiled with the m//x flag
### So "eXtended features" are implied
my $mac_rgx = qr/(?:$xBp(:|-)){5}$xBp/;					### captures the delim in $1
my $vendormac_rgx = qr/((?:$xBp(:|-)){2}$xBp)(?::|-)(?:$xBp(?::|-)){2}$xBp/;	### $1 = delim; $2 = vendor_id_bytes;
my $mac_nc_rgx = qr/(?:$xBp(?:\:|-)){5}(?:\:|-)$xBp/;
my $TLDs = qr/(?:com|net|org|edu|us|co.uk|biz|info)/;
my $email_rgx = qr/[0-9a-zA-Z_.-]+\@(?:[0-9a-zA-Z-]+\.){1,3}$TLDs/;
my $content = "";
my (%found_ips, %obfusips, %found_macs, %found_mail);


print "mac_nc_rgx		==>	$mac_nc_rgx \n";
print "vendormac_rgx 		==>	$vendormac_rgx \n";

open IN, "<$input" or die colored("There was a peoblem opening the input file ($input): $! \n", "bold red");
while (my $line = <IN>) { 
	while ($line =~ /($ip_rgx)/xg) {
		my $ip = $1;
		$found_ips{$ip}++;
		if ($smartip) { &obfusip($ip); }
	}
	while ($line =~ /($mac_nc_rgx)/xg) {
		my $mac =~ $1;
		$found_macs{$mac}++;
	}
	while ($line =~ /($email_rgx)/xg) {
		my $mail = $1;
		$found_mail{$mail}++;
	}
	$content .= $line; 
}
close IN or die colored("There was a problem closing the input file ($input): $! \n", "bold red");

print "Found ".scalar(keys(%found_ips))." total IPs. \n";
print "Obfuscated ".scalar(keys(%obfusips))." IPs. \n" if ($smartip);;
#print Dumper(\%obfusips);
print "Found ".scalar(keys(%found_macs))." total MACs. \n";

if (defined($cleanip)) {
	if ($cleanip =~ /^all$/i) {
		foreach my $ip ( keys %found_ips ) {
			if ($smartip) { $content =~ s/$ip/$obfusips{$ip}/xsg; } 
			else { $content =~ s/$ip/d.e.a.d/xsg; }
		}
	} else {
		if ($smartip) { $content =~ s/$cleanip/$obfusips{$cleanip}/xsg; }
		else { $content =~ s/$cleanip/d.e.a.d/xsg; }
	}
}

if (defined($cleanmac)) {
	if ($cleanmac =~ /^all$/i) { 
		foreach my $mac ( keys %found_macs ) {
			if ($vendormac) { $content =~ s/$vendormac_rgx/$2$1de$1ad$1bf/xsg; }
			else { $content =~ s/$mac/de$1ad$1be$1ef$1de$1ad/xsg; }
		}
	} elsif ($cleanmac =~ /$mac_rgx/x) { 
		if ($vendormac) { $content =~ s/$vendormac_rgx/$2$1de$1ad$1bf/xsg; }
		else { $content =~ s/$cleanmac/de$1ad$1be$1ef$1de$1ad/xsg; }
	}
}

if (defined($cleanmail)) {
	if ($cleanmail =~ /^all$/i) { $content =~ s/$email_rgx/deadbeef\@example.com/xsg; }
	elsif ($cleanmail =~ /$email_rgx/x) { $content =~ s/$cleanmail/deadbeef\@example.com/xsg; }
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
--smartip				If specified, will randomize the 2nd and 3rd octet of the resultant IP address within
						the 10.0.0.0/8 RFC1918 space.  Only applies to the --ip obfuscation option.
--vendormac				If specified, will leave the first 6 bytes of the MAC address to be obfuscated.  This
						can later be looked up to associate the MAC with its vendor.

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
