#!/usr/bin/env rakupp
# Getopt::Long::Grammar — The one thing to know
# https://raku.online/modules/getopt-long-grammar/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Getopt::Long::Grammar
#     rakupp 03-space-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Getopt::Long::Grammar;

for 'mytool --verbose file.txt',
    'mytool --verbose=1 file.txt',
    'mytool file.txt --verbose' -> $line {
    my %res = getopt-interpret($line);
    say $line;
    say '  options : ', %res<options>
        ?? %res<options>.keys.sort.map({ "$_=" ~ %res<options>{$_}.gist }).join(' ')
        !! '(none)';
    say '  args    : ', %res<arguments> ?? %res<arguments>.join(' ') !! '(none)';
}

# Output:
#     mytool --verbose file.txt
#       options : verbose=file.txt
#       args    : (none)
#     mytool --verbose=1 file.txt
#       options : verbose=1
#       args    : file.txt
#     mytool file.txt --verbose
#       options : verbose=True
#       args    : file.txt
