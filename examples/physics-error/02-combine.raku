#!/usr/bin/env rakupp
# Physics::Error — Combining
# https://raku.online/modules/physics-error/#combining
#
# Install what it needs, then run it:
#     rakupp install Physics::Error
#     rakupp 02-combine.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Physics::Error;

my $a = Error.new(:error(3)); $a.bind-mea-value(100);
my $b = Error.new(:error(4)); $b.bind-mea-value(100);

say 'a = 3, b = 4, both on a measured 100';
say '  a.add-abs(b) returns : ', $a.add-abs($b), '   (a Real, not an Error)';
say '  a.absolute is now    : ', $a.absolute, '   — add-abs MUTATED a';
say '';
my $c = Error.new(:error(3)); $c.bind-mea-value(100);
say '  c.add-rel(b) returns : ', $c.add-rel($b);
say '  c.absolute is still  : ', $c.absolute, '   — add-rel did not';

# Output:
#     a = 3, b = 4, both on a measured 100
#       a.add-abs(b) returns : 7   (a Real, not an Error)
#       a.absolute is now    : 7   — add-abs MUTATED a
#     
#       c.add-rel(b) returns : 0.07
#       c.absolute is still  : 3   — add-rel did not
