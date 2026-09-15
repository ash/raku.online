#!/usr/bin/env rakupp
# P5chr — Where the two engines differ
# https://raku.online/modules/p5chr/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install P5chr
#     rakupp 04-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5chr;

say 'the portable rule is simple: use this pair for the Perl argument';
say 'handling, and core Raku for anything above 127.';
say '';
say 'a wrapper that gives you both:';
sub p5-chr($n) { $n <= 127 ?? chr($n) !! $n.chr }
for 65, 200, 0x2603 -> $n {
    say sprintf('  p5-chr(%5d).ords = %-8s  really that codepoint ? %s',
                $n, p5-chr($n).ords.raku, p5-chr($n).ords[0] == $n);
}
say '';
say 'the distribution is one of lizmat`s P5 family — each supplies one';
say 'or two Perl builtins under their Perl names and semantics, so a port';
say 'can proceed routine by routine rather than all at once.';

# Output:
#     the portable rule is simple: use this pair for the Perl argument
#     handling, and core Raku for anything above 127.
#     
#     a wrapper that gives you both:
#       p5-chr(   65).ords = (65,).Seq  really that codepoint ? True
#       p5-chr(  200).ords = (200,).Seq  really that codepoint ? True
#       p5-chr( 9731).ords = (9731,).Seq  really that codepoint ? True
#     
#     the distribution is one of lizmat`s P5 family — each supplies one
#     or two Perl builtins under their Perl names and semantics, so a port
#     can proceed routine by routine rather than all at once.
