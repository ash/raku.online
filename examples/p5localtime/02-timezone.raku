#!/usr/bin/env rakupp
# P5localtime — The one thing to know
# https://raku.online/modules/p5localtime/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install P5localtime
#     rakupp 02-timezone.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5localtime;

my $before = localtime(Scalar, 0);
%*ENV<TZ> = 'UTC';
my $after = localtime(Scalar, 0);
say $before eq $after;
say gmtime(Scalar, 0);
say gmtime(0)[9];

# Output:
#     True
#     Thu Jan  1 00:00:00 1970
#     0
