#!/usr/bin/env rakupp
# AlgorithmsIT — The one thing to know
# https://raku.online/modules/algorithmsit/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install AlgorithmsIT
#     rakupp 04-iterable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use AlgorithmsIT::Classes;

my $a = ArrayOneBased.new('abc');
say 'it claims to do Iterable : ', ($a ~~ Iterable);
say '';
say 'so a guard that checks for iterability passes — and then';
say '`for $a { … }` quietly does nothing at all on Rakudo: no exception,';
say 'no warning, no elements. On Raku++ it runs once with $_ bound to the';
say 'object itself. Neither is what you meant.';
say '';
say 'the two working idioms:';
say '  positional slice : ', $a[1 .. $a.elems].raku;
say '  the public .arr  : ', $a.arr[1 .. *].raku, '   (index 0 is the -1 sentinel)';
say '';
say '.list gives you an undefined List type object on both engines,';
say 'and .map dies on Rakudo. Do not reach for either.';

# Output:
#     it claims to do Iterable : True
#     
#     so a guard that checks for iterability passes — and then
#     `for $a { … }` quietly does nothing at all on Rakudo: no exception,
#     no warning, no elements. On Raku++ it runs once with $_ bound to the
#     object itself. Neither is what you meant.
#     
#     the two working idioms:
#       positional slice : ("a", "b", "c")
#       the public .arr  : ("a", "b", "c")   (index 0 is the -1 sentinel)
#     
#     .list gives you an undefined List type object on both engines,
#     and .map dies on Rakudo. Do not reach for either.
