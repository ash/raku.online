#!/usr/bin/env rakupp
# P5length — The one thing to know
# https://raku.online/modules/p5length/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install P5length
#     rakupp 02-undef.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5length;

my $r = length(Str);
say 'length(Str)         : ', $r.raku;
say '  .WHAT             : ', $r.WHAT.^name;
say '  .defined          : ', $r.defined;
say '  == 0              : ', ($r == 0);
say '';
say 'so the Perl guard ports correctly:';
say '  if defined length($x) { … }  -> ', $r.defined;
say '';
say 'and the one a Raku programmer would reach for does not:';
say '  if length($x) == 0 { … }     -> ', ($r == 0);
say '';
say 'an empty string and an undefined one are indistinguishable by that';
say 'test, which is exactly the distinction Perl`s length exists to make.';
say '';
say 'test .defined, not == 0:';
for 'hello', '', Str -> $x {
    my $l = length($x);
    say sprintf('  %-8s -> %s', $x.raku,
                $l.defined ?? "length $l" !! 'undefined');
}

# Output:
#     length(Str)         : Str
#       .WHAT             : Str
#       .defined          : False
#       == 0              : True
#     
#     so the Perl guard ports correctly:
#       if defined length($x) { … }  -> False
#     
#     and the one a Raku programmer would reach for does not:
#       if length($x) == 0 { … }     -> True
#     
#     an empty string and an undefined one are indistinguishable by that
#     test, which is exactly the distinction Perl`s length exists to make.
#     
#     test .defined, not == 0:
#       "hello"  -> length 5
#       ""       -> length 0
#       Str      -> undefined
