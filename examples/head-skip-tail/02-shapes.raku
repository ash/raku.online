#!/usr/bin/env rakupp
# head-skip-tail — The argument shapes
# https://raku.online/modules/head-skip-tail/#the-argument-shapes
#
# Install what it needs, then run it:
#     rakupp install head-skip-tail
#     rakupp 02-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use head-skip-tail;

my @a = 1, 2, 3, 4, 5;
my @b = 10, 20;

say 'the +values slurpy uses the ONE-ARG rule, so two arrays stay two:';
say '  head(2, @a, @b) = ', head(2, @a, @b).raku;
say '  head(2, 7, 8, 9) = ', head(2, 7, 8, 9).raku;
say '';
say 'every result is a Seq:';
say '  ', head(2, @a).WHAT.^name;
say '';
say 'degenerate counts do not complain:';
for 0, -1, 99 -> $n {
    say sprintf('  head(%3d, @a) = %s   skip(%3d, @a) = %s',
                $n, head($n, @a).raku, $n, skip($n, @a).raku);
}
say '';
say 'and head() with no list at all is an empty Seq, not an error:';
say '  head(2) = ', head(2).raku;
say '';
say 'a lazy source is where the two engines part — a +@ slurpy is always';
say 'eager on Raku++, and an infinite .map collapses to nothing there.';
say 'Take the head with the METHOD when the source is lazy:';
say '  (1..Inf).map(* * 2).head(3) = ', (1..Inf).map(* * 2).head(3).raku;

# Output:
#     the +values slurpy uses the ONE-ARG rule, so two arrays stay two:
#       head(2, @a, @b) = ([1, 2, 3, 4, 5], [10, 20]).Seq
#       head(2, 7, 8, 9) = (7, 8).Seq
#     
#     every result is a Seq:
#       Seq
#     
#     degenerate counts do not complain:
#       head(  0, @a) = ().Seq   skip(  0, @a) = (1, 2, 3, 4, 5).Seq
#       head( -1, @a) = ().Seq   skip( -1, @a) = (1, 2, 3, 4, 5).Seq
#       head( 99, @a) = (1, 2, 3, 4, 5).Seq   skip( 99, @a) = ().Seq
#     
#     and head() with no list at all is an empty Seq, not an error:
#       head(2) = ().Seq
#     
#     a lazy source is where the two engines part — a +@ slurpy is always
#     eager on Raku++, and an infinite .map collapses to nothing there.
#     Take the head with the METHOD when the source is lazy:
#       (1..Inf).map(* * 2).head(3) = (2, 4, 6).Seq
