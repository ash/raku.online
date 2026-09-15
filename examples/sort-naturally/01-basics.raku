#!/usr/bin/env rakupp
# Sort::Naturally — Sorting naturally
# https://raku.online/modules/sort-naturally/#sorting-naturally
#
# Install what it needs, then run it:
#     rakupp install Sort::Naturally
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Sort::Naturally;

my @files = <file10.txt file2.txt file1.txt File3.TXT>;
say 'plain .sort : ', @files.sort.join(' ');
say 'naturally   : ', @files.sort({ .&naturally }).join(' ');
say '';
say 'two things changed: numeric order for the digits, and case folding —';
say 'plain .sort puts File3.TXT first because F is 70 and f is 102.';
say '';
my @versions = <v1.2.10 v1.2.9 v1.10.0 v1.9.0>;
say 'versions, plain : ', @versions.sort.join(' ');
say 'versions, nat   : ', @versions.sort({ .&naturally }).join(' ');

# Output:
#     plain .sort : File3.TXT file1.txt file10.txt file2.txt
#     naturally   : file1.txt file2.txt File3.TXT file10.txt
#     
#     two things changed: numeric order for the digits, and case folding —
#     plain .sort puts File3.TXT first because F is 70 and f is 102.
#     
#     versions, plain : v1.10.0 v1.2.10 v1.2.9 v1.9.0
#     versions, nat   : v1.2.9 v1.2.10 v1.9.0 v1.10.0
