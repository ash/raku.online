#!/usr/bin/env rakupp
# P5length — Where the two engines differ
# https://raku.online/modules/p5length/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install P5length
#     rakupp 03-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5length;

say 'the portable idiom is the Perl one:';
sub describe($x) {
    my $l = length($x);
    $l.defined ?? "$l characters" !! 'undefined'
}
for 'hello', '', Str, 42 -> $x {
    say sprintf('  %-8s -> %s', $x.raku, describe($x));
}
say '';
say 'and the end state, once the port is done, is core Raku:';
say '  "hello".chars     = ', 'hello'.chars;
say '  (Str).chars       — raises rather than answering an undefined value';
say '  ($x // "").chars  = ', ((Str) // '').chars;
say '';
say 'note the last line: core Raku pushes you to decide what an undefined';
say 'string means, which is the change the port is really making.';

# Output:
#     the portable idiom is the Perl one:
#       "hello"  -> 5 characters
#       ""       -> 0 characters
#       Str      -> undefined
#       42       -> 2 characters
#     
#     and the end state, once the port is done, is core Raku:
#       "hello".chars     = 5
#       (Str).chars       — raises rather than answering an undefined value
#       ($x // "").chars  = 0
#     
#     note the last line: core Raku pushes you to decide what an undefined
#     string means, which is the change the port is really making.
