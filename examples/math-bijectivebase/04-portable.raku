#!/usr/bin/env rakupp
# Math::BijectiveBase — Where the two engines differ
# https://raku.online/modules/math-bijectivebase/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Math::BijectiveBase
#     rakupp 04-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Math::BijectiveBase;

# a spreadsheet-column helper that is total over the values it accepts
sub column(Int $n) {
    die "column numbers start at 1, got $n" unless $n > 0;
    to-bijective26($n)
}
for 1, 27, 703, 0 -> $n {
    my $c = try column($n);
    say sprintf('  column(%4d) -> %s', $n, $! ?? $!.message !! $c);
}
say '';
say 'the five alphabets are reachable as `our` arrays if you need to';
say 'inspect one: Math::BijectiveBase::@base26-alphabet and friends.';
say 'their declared sizes are 26, 35, 52, 62 and 10.';

# Output:
#       column(   1) -> A
#       column(  27) -> AA
#       column( 703) -> AAA
#       column(   0) -> column numbers start at 1, got 0
#     
#     the five alphabets are reachable as `our` arrays if you need to
#     inspect one: Math::BijectiveBase::@base26-alphabet and friends.
#     their declared sizes are 26, 35, 52, 62 and 10.
