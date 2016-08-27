# log-sanitizer
Strips out IPs, MAC addresses, email addresses (?) and makes them more anonymous.

## log-sanitizer.pl
This is the one that does the magic.

# TO DO:
* implement all of the features in the current help/usage statement (see below)
* mac "vendor" mode -- leave the first 6 bytes (a.k.a. the vendor id) of found MAC addresses
* rfc1918 mode
	* rfc1918 "smart" mode - this will generate a random 2nd and 3rd octet and assign it to a given IP.  That randomly generated IP will replace all iterations of the "trigger" ip within the input file.

## Usage Statment:
```

log-sanitizer.pl [-hvx] [--ip] [--mac] [--email] [-i|--input] [-o|--output]

Where:

-h|--help				Displays this useful message, then exits.
-v|--verbose				Increases the level of output.  Use multiple times for more verbose output.
-i|--input <file>			Specifies the file to sanitize.
-o|--output <file>			Specifies the the file to save the sanitized output.
--ip <ip|all>				Specifies a specific IP to sanitize, or all.
--mac <mac|all>				Specifies a specific MAC address to sanitize, or all.
--email <email|all>			Specifies a specific email address to sanitize, or all.
-x|--hex


```
