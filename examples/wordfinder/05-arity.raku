#!/usr/bin/env rakupp
# wordfinder — Where the two engines differ
# https://raku.online/modules/wordfinder/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install wordfinder
#     rakupp 05-arity.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use wordfinder;

my $r = check_array('tea');
say 'check_array with one argument returned : ', $r.raku;
say '';
say 'so `for check_array($x) { … }` iterates over True rather than over';
say 'nothing. The same is true for four or more arguments. Check the';
say 'result type, or wrap the call.';
say '';
say 'a dictionary word that is falsy as a string is dropped by the';
say 'internal `if $checked_var` filter:';
say '  check_array("0", ["0"]) = ', check_array('0', ['0']).raku;

# Output:
#     Please supply a string of letters and a list of words!
#     check_array with one argument returned : Bool::True
#     
#     so `for check_array($x) { … }` iterates over True rather than over
#     nothing. The same is true for four or more arguments. Check the
#     result type, or wrap the call.
#     
#     a dictionary word that is falsy as a string is dropped by the
#     internal `if $checked_var` filter:
#       check_array("0", ["0"]) = ["0"]
