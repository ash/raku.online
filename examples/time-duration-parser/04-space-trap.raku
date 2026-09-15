#!/usr/bin/env rakupp
# Time::Duration::Parser — The one thing to know
# https://raku.online/modules/time-duration-parser/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Time::Duration::Parser
#     rakupp 04-space-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Time::Duration::Parser;

for '1h', '1 h', '90m', '90 m', '1h30m', '1 h 30 m' -> $s {
    my $v = duration-to-seconds($s);
    say sprintf('%-10s -> %-8s defined=%s', "'$s'",
        $v.defined ?? $v.Int.Str !! 'undefined', $v.defined);
}
say '';
my $bad = duration-to-seconds('30m');
say 'duration-to-seconds("30m") is ', $bad.defined ?? 'defined' !! 'undefined';
say 'and + 0 turns it into ', ($bad // 0) + 0;

# Output:
#     '1h'       -> undefined defined=False
#     '1 h'      -> 3600     defined=True
#     '90m'      -> undefined defined=False
#     '90 m'     -> 5400     defined=True
#     '1h30m'    -> undefined defined=False
#     '1 h 30 m' -> 5400     defined=True
#     
#     duration-to-seconds("30m") is undefined
#     and + 0 turns it into 0
