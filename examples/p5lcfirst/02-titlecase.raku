#!/usr/bin/env rakupp
# P5lcfirst — The one thing to know
# https://raku.online/modules/p5lcfirst/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install P5lcfirst
#     rakupp 02-titlecase.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5lcfirst;

my $dz = "\c[LATIN SMALL LETTER DZ WITH CARON]";
say 'the digraph ǆ (U+01C6):';
say '  ucfirst  -> ', ucfirst($dz).raku, '  ', ucfirst($dz).substr(0, 1).uniname;
say '  .tc      -> ', $dz.tc.raku, '  ', $dz.tc.substr(0, 1).uniname;
say '';
say 'Unicode gives that character three cases, not two: a lowercase ǆ, a';
say 'titlecase ǅ and an uppercase Ǆ. ucfirst picks the uppercase one and';
say '.tc picks the titlecase one, and for a word-initial letter the';
say 'titlecase form is the correct typography.';
say '';
say 'the same split applies to the other digraphs:';
for "\c[LATIN SMALL LETTER LJ]", "\c[LATIN SMALL LETTER NJ]",
    "\c[LATIN SMALL LETTER DZ]" -> $c {
    say sprintf('  %s : ucfirst %-4s   .tc %-4s   differ ? %s',
                $c, ucfirst($c).raku, $c.tc.raku, ucfirst($c) ne $c.tc);
}
say '';
say 'for ASCII, and for every ordinary accented letter, the two agree:';
say '  ucfirst("hello") eq "hello".tc : ', ucfirst('hello') eq 'hello'.tc;
say '  ucfirst("élan")  eq "élan".tc  : ',
    ucfirst("\c[LATIN SMALL LETTER E WITH ACUTE]lan") eq "\c[LATIN SMALL LETTER E WITH ACUTE]lan".tc;

# Output:
#     the digraph ǆ (U+01C6):
#       ucfirst  -> "Ǆ"  LATIN CAPITAL LETTER DZ WITH CARON
#       .tc      -> "ǅ"  LATIN CAPITAL LETTER D WITH SMALL LETTER Z WITH CARON
#     
#     Unicode gives that character three cases, not two: a lowercase ǆ, a
#     titlecase ǅ and an uppercase Ǆ. ucfirst picks the uppercase one and
#     .tc picks the titlecase one, and for a word-initial letter the
#     titlecase form is the correct typography.
#     
#     the same split applies to the other digraphs:
#       ǉ : ucfirst "Ǉ"    .tc "ǈ"    differ ? True
#       ǌ : ucfirst "Ǌ"    .tc "ǋ"    differ ? True
#       ǳ : ucfirst "Ǳ"    .tc "ǲ"    differ ? True
#     
#     for ASCII, and for every ordinary accented letter, the two agree:
#       ucfirst("hello") eq "hello".tc : True
#       ucfirst("élan")  eq "élan".tc  : True
