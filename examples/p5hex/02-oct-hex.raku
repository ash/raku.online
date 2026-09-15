#!/usr/bin/env rakupp
# P5hex — The one thing to know
# https://raku.online/modules/p5hex/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install P5hex
#     rakupp 02-oct-hex.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5hex;

for '0xff', '0XFF', '0b101', '0o17', '755' -> $s {
    my $h = hex($s);
    say sprintf('  oct(%-8s) = %-6s   hex(%-8s) = %s',
                $s.raku, oct($s), $s.raku,
                $h.defined ?? $h.Str !! 'not a number');
}
say '';
say 'Perl reads 0xff through oct as 255. Here the 0 is consumed as an';
say 'octal zero, the x ends the number, and you get 0 — a perfectly';
say 'ordinary-looking result from a function whose job is to return';
say 'numbers.';
say '';
say 'if your ported code feeds oct a string whose base is carried by a';
say 'prefix, dispatch yourself:';
sub p5-oct(Str $s) {
    given $s {
        when /^ '0' <[xX]> / { hex($s) }
        when /^ '0' <[bB]> / { oct($s) }
        default              { oct($s) }
    }
}
for '0xff', '0b101', '755' -> $s {
    say sprintf('  p5-oct(%-8s) = %s', $s.raku, p5-oct($s));
}

# Output:
#       oct("0xff"  ) = 0        hex("0xff"  ) = 255
#       oct("0XFF"  ) = 0        hex("0XFF"  ) = not a number
#       oct("0b101" ) = 5        hex("0b101" ) = 45313
#       oct("0o17"  ) = 15       hex("0o17"  ) = 15
#       oct("755"   ) = 493      hex("755"   ) = 1877
#     
#     Perl reads 0xff through oct as 255. Here the 0 is consumed as an
#     octal zero, the x ends the number, and you get 0 — a perfectly
#     ordinary-looking result from a function whose job is to return
#     numbers.
#     
#     if your ported code feeds oct a string whose base is carried by a
#     prefix, dispatch yourself:
#       p5-oct("0xff"  ) = 255
#       p5-oct("0b101" ) = 5
#       p5-oct("755"   ) = 493
