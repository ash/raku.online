#!/usr/bin/env rakupp
# Unicode::PRECIS — The one thing to know
# https://raku.online/modules/unicode-precis/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Unicode::PRECIS
#     rakupp 03-width-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Unicode::PRECIS;
use Unicode::PRECIS::Identifier::UsernameCaseMapped;

my $cm = Unicode::PRECIS::Identifier::UsernameCaseMapped.new;
my $fw = "\c[FULLWIDTH LATIN CAPITAL LETTER A]" ~ "\c[FULLWIDTH LATIN SMALL LETTER B]";

say 'input codepoints      : ', $fw.ords.List.raku;
say 'width-mapping-rule    : ', $cm.width-mapping-rule($fw).raku;
say 'which is just those numbers concatenated : ',
    $cm.width-mapping-rule($fw) eq $fw.ords.join('');
say 'a real width mapping would give          : ',
    $fw.comb.map({ my $o = .ord; 0xFF01 <= $o <= 0xFF5E ?? ($o - 0xFEE0).chr !! $_ }).join.raku;
say '';
say 'and prepare and enforce disagree about it:';
say '  prepare : ', $cm.prepare($fw).raku;
say '  enforce : ', $cm.enforce($fw) ~~ Str ?? $cm.enforce($fw).raku !! 'rejected';

# Output:
#     input codepoints      : (65313, 65346)
#     width-mapping-rule    : "6531365346"
#     which is just those numbers concatenated : True
#     a real width mapping would give          : "Ab"
#     
#     and prepare and enforce disagree about it:
#       prepare : "6531365346"
#       enforce : rejected
