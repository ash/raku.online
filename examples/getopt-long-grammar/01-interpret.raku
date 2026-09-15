#!/usr/bin/env rakupp
# Getopt::Long::Grammar — Interpreting a command line
# https://raku.online/modules/getopt-long-grammar/#interpreting-a-command-line
#
# Install what it needs, then run it:
#     rakupp install Getopt::Long::Grammar
#     rakupp 01-interpret.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Getopt::Long::Grammar;

my %res = getopt-interpret('mytool --verbose --output=out.txt --level=3');
say 'command : ', %res<command>;
say 'options : ', %res<options>.keys.sort.map({ "$_=" ~ %res<options>{$_} }).join(' ');
say 'args    : ', (%res<arguments> // ()).elems, ' positional';

# Output:
#     command : mytool
#     options : level=3 output=out.txt verbose=True
#     args    : 0 positional
