#!/usr/bin/env rakupp
# Data::Generators — Numbers and date-times
# https://raku.online/ecosystem/data-generators/#numbers-and-date-times
#
# Install what it needs, then run it:
#     rakupp install Data::Generators
#     rakupp 07-date-times.raku
#
# Run under Raku++ 3.5.1 (dev build) and Rakudo 2026.07 every time the site is
# built; the build fails if the output below stops matching.

use Data::Generators;

my @dt = random-date-time(size => 100);
say @dt.elems;
say so @dt.all ~~ DateTime;
say so @dt.map(*.year).all ~~ 1900..2100;

my $min = DateTime.new('2024-01-01T00:00:00Z');
my $max = DateTime.new('2024-12-31T23:59:59Z');
say so random-date-time(:$min, :$max, size => 50).map(*.year).all == 2024;

# Output:
#     100
#     True
#     True
#     True
