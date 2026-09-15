#!/usr/bin/env rakupp
# Terminal::Spinners — The one thing to know
# https://raku.online/modules/terminal-spinners/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Terminal::Spinners
#     rakupp 02-side-effects.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Terminal::Spinners;

my $s = Spinner.new;
say $s.next(:now).raku;
say $s.next.raku;

my $t0 = now;
$s.next(:nop);
my $quiet = now - $t0;
my $t1 = now;
$s.next;
my $drew = now - $t1;
say $quiet < 0.02;
say $drew >= 0.05;

say Bar.new.show(10, :nop).comb.grep("\b").elems;

# Output:
#     |"|"
#     /"\b/"
#     \True
#     True
#     80
