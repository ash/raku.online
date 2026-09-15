#!/usr/bin/env rakupp
# Algorithm::Elo — The flags
# https://raku.online/modules/algorithm-elo/#the-flags
#
# Install what it needs, then run it:
#     rakupp install Algorithm::Elo
#     rakupp 02-flags.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::Elo;

sub attempt($label, &c) {
    my $r = try c();
    say sprintf('%-30s %s', $label, $! ?? $!.message !! $r.List.raku);
}

attempt 'no flag at all',          { calculate-elo(1600, 1600) };
attempt ':left and :right',        { calculate-elo(1600, 1600, :left, :right) };
attempt 'all three',               { calculate-elo(1600, 1600, :left, :right, :draw) };
attempt ':!left (an explicit No)', { calculate-elo(1600, 1600, :!left) };
attempt 'just :draw',              { calculate-elo(1600, 1600, :draw) };

# Output:
#     no flag at all                 :left, :right, and :draw are mutually exclusive
#     :left and :right               :left, :right, and :draw are mutually exclusive
#     all three                      :left, :right, and :draw are mutually exclusive
#     :!left (an explicit No)        :left, :right, and :draw are mutually exclusive
#     just :draw                     (1600, 1600)
