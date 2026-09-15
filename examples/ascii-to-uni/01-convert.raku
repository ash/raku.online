#!/usr/bin/env rakupp
# ASCII::To::Uni — Converting a string
# https://raku.online/modules/ascii-to-uni/#converting-a-string
#
# Install what it needs, then run it:
#     rakupp install ASCII::To::Uni
#     rakupp 01-convert.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use ASCII::To::Uni;

my Str $src = 'my @a = 1,2,3; say @a (|) @b; say $x (elem) %h; my $s = set();';
my $returned = convert-string($src);

say 'the return value : ', $returned.raku;
say 'the variable     : ', $src;
say '';
my Str $two = 'if $a (<=) $b and $c (>=) $d { say "..." }';
convert-string($two);
say $two;

# Output:
#     the return value : Any
#     the variable     : my @a = 1,2,3; say @a ∪ @b; say $x ∈ %h; my $s = ∅;
#     
#     if $a ⊆ $b and $c ⊇ $d { say "…" }
