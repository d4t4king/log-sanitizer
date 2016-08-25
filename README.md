# log-sanitizer
Strips out IPs, MAC addresses, email addresses (?) and makes them more anonymous.

## log-sanitizer.pl
This is the one that does the magic.

# TO DO:
* implement all of the features in the current help/usage statement
* mac "vendor" mode -- leave the first 6 bytes (a.k.a. the vendor id) of found MAC addresses
* rfc1918 mode
	* rfc1918 "smart" mode - this will generate a random 2nd and 3rd octet and assign it to a given IP.  That randomly generated IP will replace all iterations of the "trigger" ip within the input file.
