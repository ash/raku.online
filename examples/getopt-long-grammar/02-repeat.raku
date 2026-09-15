#!/usr/bin/env rakupp
# Getopt::Long::Grammar — Repeated options
# https://raku.online/modules/getopt-long-grammar/#repeated-options
#
# Install what it needs, then run it:
#     rakupp install Getopt::Long::Grammar
#     rakupp 02-repeat.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Getopt::Long::Grammar;

my %g = getopt-interpret('build --define=A --define=B --define=C');
say 'gathered   : ', %g<options><define>.List.join(',');
say '';
my %r = getopt-interpret('build --define=A --define=B', :!gather);
say 'raw pairs  : ', %r<options>.map({ "{$_<name>}={$_<value>}" }).join(' ');

# Output:
#     gathered   : A,B,C
#     
#     raw pairs  : define=A define=B
