#!/usr/bin/env rakupp
# Term::Size — The one thing to know
# https://raku.online/modules/term-size/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Term::Size
#     rakupp 02-zero.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Term::Size;

my $ts = Term::Size.new;
my $r = $ts.populate;               # a Failure here, if there is no terminal
$r.so if $r ~~ Failure;             # mark it handled so it cannot detonate

my $w = $ts.term-width-cells;
say 'term-width-cells : ', $w;
say '  type           : ', $w.WHAT.^name;
say '  ~~ Failure     : ', ($w ~~ Failure);
say '';
say 'so the natural code —';
say '  my $t = Term::Size.new; $t.populate; say $t.term-width-cells;';
say '— prints 0, with no warning anywhere.';
say '';
say 'and the usual defensive idiom hides it:';
say '  width || 80  = ', ($w || 80), '   <- 80 in BOTH the "no terminal"';
say '                        case and a hypothetical real 0-column one';
say '  width - 2    = ', ($w - 2), '  <- a negative layout';
say '';
say 'check populate`s return value; nothing downstream will tell you:';
sub terminal-width(Int $fallback = 80) {
    my $t = Term::Size.new;
    my $r = $t.populate;
    return $fallback if $r ~~ Failure;
    $t.term-width-cells || $fallback
}
say '  terminal-width() = ', terminal-width();

# Output:
#     term-width-cells : 0
#       type           : Int
#       ~~ Failure     : False
#     
#     so the natural code —
#       my $t = Term::Size.new; $t.populate; say $t.term-width-cells;
#     — prints 0, with no warning anywhere.
#     
#     and the usual defensive idiom hides it:
#       width || 80  = 80   <- 80 in BOTH the "no terminal"
#                             case and a hypothetical real 0-column one
#       width - 2    = -2  <- a negative layout
#     
#     check populate`s return value; nothing downstream will tell you:
#       terminal-width() = 80
