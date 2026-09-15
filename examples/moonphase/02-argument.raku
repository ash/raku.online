#!/usr/bin/env rakupp
# Moonphase — The argument is Unix seconds
# https://raku.online/modules/moonphase/#the-argument-is-unix-seconds
#
# Install what it needs, then run it:
#     rakupp install Moonphase
#     rakupp 02-argument.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Moonphase;

my $ts = 1503354360;
say 'Int seconds        : ', moonphase($ts).round(0.000001);
say 'the same as a Str  : ', moonphase("$ts").round(0.000001);
say '';
say 'a Date numifies to its MJD daycount, not to seconds:';
my $d = Date.new(2017, 8, 21);
say '  Date.new(2017,8,21) numifies to ', +$d;
say '  moonphase(that)     = ', moonphase($d).round(0.000001), '  <- meaningless';
say '';
say 'milliseconds are accepted too, and equally meaningless.';
say 'convert to seconds yourself: $dt.posix.Int';
say '  moonphase($dt.posix.Int) = ',
    moonphase(DateTime.new(2017, 8, 21, 18, 26, 0).posix.Int).round(0.000001);

# Output:
#     Int seconds        : 0.038169
#     the same as a Str  : 0.038169
#     
#     a Date numifies to its MJD daycount, not to seconds:
#       Date.new(2017,8,21) numifies to 57986
#       moonphase(that)     = 4.861886  <- meaningless
#     
#     milliseconds are accepted too, and equally meaningless.
#     convert to seconds yourself: $dt.posix.Int
#       moonphase($dt.posix.Int) = -0.000162
