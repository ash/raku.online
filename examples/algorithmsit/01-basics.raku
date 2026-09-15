#!/usr/bin/env rakupp
# AlgorithmsIT — Matching
# https://raku.online/modules/algorithmsit/#matching
#
# Install what it needs, then run it:
#     rakupp install AlgorithmsIT
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use AlgorithmsIT :p1005, :p1006;
use AlgorithmsIT::Classes;

sub matches(Str $text, Str $pattern) {
    KMP-Matcher(ArrayOneBased.new($text), ArrayOneBased.new($pattern))
}

for <abababacaba ababaca>, <aaaaa aa>, <abcabcabc abc>,
    <abc zzz>, <aaa aaa> -> ($t, $p) {
    my @brute = (0 .. $t.chars - $p.chars).grep({ $t.substr($_, $p.chars) eq $p });
    say sprintf('  T=%-12s P=%-8s shifts %-14s brute %-14s %s',
                $t, $p, matches($t, $p).raku, @brute.raku,
                matches($t, $p).List eqv @brute.List ?? 'agree' !! 'DIFFER');
}
say '';
say 'the shifts are zero-based offsets into the text.';

# Output:
#       T=abababacaba  P=ababaca  shifts [2]            brute [2]            agree
#       T=aaaaa        P=aa       shifts [0, 1, 2, 3]   brute [0, 1, 2, 3]   agree
#       T=abcabcabc    P=abc      shifts [0, 3, 6]      brute [0, 3, 6]      agree
#       T=abc          P=zzz      shifts []             brute []             agree
#       T=aaa          P=aaa      shifts [0]            brute [0]            agree
#     
#     the shifts are zero-based offsets into the text.
