#!/usr/bin/env rakupp
# ASCII::To::Uni — The one thing to know
# https://raku.online/modules/ascii-to-uni/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install ASCII::To::Uni
#     rakupp 03-plus-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use ASCII::To::Uni;
use MONKEY-SEE-NO-EVAL;

my Str $prog = 'my $e = 40; my $n = $e + 2; $n';
say 'before : ', $prog;
say '  evaluates to : ', EVAL $prog;
say '';
convert-string($prog);
say 'after  : ', $prog;
my $r = try EVAL $prog;
say '  evaluates    : ', $! ?? 'no — it is a parse error now' !! 'yes';

# Output:
#     before : my $e = 40; my $n = $e + 2; $n
#       evaluates to : 42
#     
#     after  : my $e = 40; my $n = $e⁺2; $n
#       evaluates    : no — it is a parse error now
