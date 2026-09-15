#!/usr/bin/env rakupp
# Holidays::US::Federal — The one thing to know
# https://raku.online/modules/holidays-us-federal/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Holidays::US::Federal
#     rakupp 03-shape-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Holidays::US::Federal;

my %h = get-fedholidays(:year(2024), :set-id('MYSET'));

say 'the outer keys are dates : ', %h.keys.sort.head(3).join(' ');
say '';
say 'each value is another HASH, not a holiday:';
say '  %h{"2024-07-04"} is a ', %h{'2024-07-04'}.^name;
say '  its keys           : ', %h{'2024-07-04'}.keys.join(' ');
say '';
my $e = %h{'2024-07-04'}{'MYSET|jul4'};
say 'the holiday is two subscripts down : ', $e.name;
say '';
say 'and the set id you passed is nowhere on it:';
say '  $e.set-id is the empty string : ', $e.set-id eq '';

# Output:
#     the outer keys are dates : 2024-01-01 2024-01-15 2024-02-19
#     
#     each value is another HASH, not a holiday:
#       %h{"2024-07-04"} is a Hash
#       its keys           : MYSET|jul4
#     
#     the holiday is two subscripts down : Independence Day
#     
#     and the set id you passed is nowhere on it:
#       $e.set-id is the empty string : True
