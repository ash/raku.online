#!/usr/bin/env rakupp
# Getopt::Long::Grammar — Where the two engines differ
# https://raku.online/modules/getopt-long-grammar/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Getopt::Long::Grammar
#     rakupp 04-quoting.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Getopt::Long::Grammar;

my %a = getopt-interpret('mytool "quoted value"');
say 'arguments : ', %a<arguments>.List.raku;
my %b = getopt-interpret(q{mytool --name='John Smith'});
say 'options   : ', %b<options>.keys.sort.map({ "$_=" ~ %b<options>{$_} }).join(' ');

# Output:
#     arguments : ("\"quoted", "value\"")
#     options   : name='John
