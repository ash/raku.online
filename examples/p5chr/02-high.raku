#!/usr/bin/env rakupp
# P5chr — The one thing to know
# https://raku.online/modules/p5chr/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install P5chr
#     rakupp 02-high.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5chr;

for 65, 126, 127, 128, 200, 255 -> $n {
    my $c = chr($n);
    say sprintf('  chr(%5d)  .ord = %-5d  .ords = %-8s  eq %d.chr ? %s',
                $n, $c.ord, $c.ords.raku, $n, $c eq $n.chr);
}
say '';
say 'above 127 the returned string IS a question mark — .ords is (63),';
say 'its UTF-8 encoding is the single byte 0x3F, and it is not `eq` the';
say 'character core Raku would give you.';
say '';
say 'but .ord answers the number you asked for. So the obvious';
say 'round-trip check passes while the string is wrong:';
say '  chr(200).ord == 200        : ', chr(200).ord == 200;
say '  chr(200) eq 200.chr        : ', chr(200) eq 200.chr;
say '  chr(200).encode("utf8")    : ',
    chr(200).encode('utf8').list.map({ .fmt('%02X') }).join(' ');
say '  200.chr.encode("utf8")     : ',
    200.chr.encode('utf8').list.map({ .fmt('%02X') }).join(' ');
say '';
say 'a byte-oriented Perl program that walks 0..255 through chr therefore';
say 'produces the right answer for the first 128 and question marks for';
say 'the rest — and every assertion it makes with .ord still passes.';
say '';
say 'for codepoints above 127, use core Raku:';
say '  200.chr    = ', 200.chr.raku;
say '  0x2603.chr = ', 0x2603.chr.raku;

# Output:
#       chr(   65)  .ord = 65     .ords = (65,).Seq  eq 65.chr ? True
#       chr(  126)  .ord = 126    .ords = (126,).Seq  eq 126.chr ? True
#       chr(  127)  .ord = 127    .ords = (127,).Seq  eq 127.chr ? True
#       chr(  128)  .ord = 128    .ords = (63,).Seq  eq 128.chr ? False
#       chr(  200)  .ord = 200    .ords = (63,).Seq  eq 200.chr ? False
#       chr(  255)  .ord = 255    .ords = (63,).Seq  eq 255.chr ? False
#     
#     above 127 the returned string IS a question mark — .ords is (63),
#     its UTF-8 encoding is the single byte 0x3F, and it is not `eq` the
#     character core Raku would give you.
#     
#     but .ord answers the number you asked for. So the obvious
#     round-trip check passes while the string is wrong:
#       chr(200).ord == 200        : True
#       chr(200) eq 200.chr        : False
#       chr(200).encode("utf8")    : 3F
#       200.chr.encode("utf8")     : C3 88
#     
#     a byte-oriented Perl program that walks 0..255 through chr therefore
#     produces the right answer for the first 128 and question marks for
#     the rest — and every assertion it makes with .ord still passes.
#     
#     for codepoints above 127, use core Raku:
#       200.chr    = "È"
#       0x2603.chr = "☃"
