#!/usr/bin/env rakupp
# Getopt::Long — Patterns, and a signature
# https://raku.online/modules/getopt-long/#patterns-and-a-signature
#
# Install what it needs, then run it:
#     rakupp install Getopt::Long
#     rakupp 01-patterns.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Getopt::Long;

my @args = <--name=Ada -v --count 3 file.txt --tag a --tag b>;
my $opts = get-options-from(@args, 'name=s', 'verbose|v!', 'count=i', 'tag=s@');
say $opts.hash.sort.map({ .key ~ '=' ~ .value.join(',') }).join(' ');
say $opts.list;

# Output:
#     count=3 name=Ada tag=a,b verbose=True
#     (file.txt)
