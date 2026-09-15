#!/usr/bin/env rakupp
# Date::Calendar::MayaAztec — The one thing to know
# https://raku.online/modules/date-calendar-mayaaztec/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Date::Calendar::MayaAztec
#     rakupp 04-ambiguous.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Date::Calendar::Maya;

my %args = month => 5, day => 1, clerical-index => 18, clerical-number => 12;
for <before on-or-before after> -> $which {
    my $m = Date::Calendar::Maya.new(|%args, |($which => Date.new(2020, 6, 20)));
    say sprintf('  :%-14s 2020-06-20 -> %s  %s', $which, $m.to-date, $m.long-count);
}
say '';
my $floating = Date::Calendar::Maya.new(|%args, nearest => Date.new(2020, 6, 20));
say 'pinned with :nearest      -> ', $floating.to-date;
say '';
say 'with NO reference date the module reaches for Date.today, so the';
say 'same program answers a different date 27 years from now — silently.';
say 'always pass :before / :on-or-before / :after / :nearest.';

# Output:
#       :before         2020-06-20 -> 1968-07-03  12.17.14.15.18
#       :on-or-before   2020-06-20 -> 2020-06-20  13.0.7.10.18
#       :after          2020-06-20 -> 2072-06-07  13.3.0.5.18
#     
#     pinned with :nearest      -> 2020-06-20
#     
#     with NO reference date the module reaches for Date.today, so the
#     same program answers a different date 27 years from now — silently.
#     always pass :before / :on-or-before / :after / :nearest.
