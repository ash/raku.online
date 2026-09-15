#!/usr/bin/env rakupp
# Operator::feq — Where the two engines differ
# https://raku.online/modules/operator-feq/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Operator::feq
#     rakupp 05-edges.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Operator::feq;

say 'the empty string is a hard failure on both engines:';
my $r = try ('' feq '');
say '  "" feq "" -> ', $! ?? 'threw' !! $r.raku;
say '  the message says "Cannot coerce \'\' to Str", which is misleading —';
say '  the coercion succeeded, the code just tests the result for truth.';
say '';
say 'an undefined operand likewise:';
my $u = try (Str feq 'abc');
say '  Str feq "abc" -> ', $! ?? 'threw' !! $u.raku;
say '';
say 'guard both ends:';
sub fuzzy(Str:D $a, Str:D $b, :$threshold = 0.1) {
    return $a eq $b unless $a.chars && $b.chars;
    my $*FEQTHRESHOLD = $threshold;
    $a feq $b
}
for ('', ''), ('cat', 'cot'), ('abcdefghij', 'abcdefghik') -> ($a, $b) {
    say sprintf('  fuzzy(%-12s, %-12s) = %s', $a.raku, $b.raku, fuzzy($a, $b));
}

# Output:
#     the empty string is a hard failure on both engines:
#       "" feq "" -> threw
#       the message says "Cannot coerce '' to Str", which is misleading —
#       the coercion succeeded, the code just tests the result for truth.
#     
#     an undefined operand likewise:
#       Str feq "abc" -> threw
#     
#     guard both ends:
#       fuzzy(""          , ""          ) = True
#       fuzzy("cat"       , "cot"       ) = False
#       fuzzy("abcdefghij", "abcdefghik") = True
