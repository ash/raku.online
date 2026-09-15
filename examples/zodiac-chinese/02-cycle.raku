#!/usr/bin/env rakupp
# Zodiac::Chinese — The cycle is genuinely sixty long
# https://raku.online/modules/zodiac-chinese/#the-cycle-is-genuinely-sixty-long
#
# Install what it needs, then run it:
#     rakupp install Zodiac::Chinese
#     rakupp 02-cycle.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Zodiac::Chinese;

sub triple($y) {
    my $z = ChineseZodiac.new(DateTime.new(year => $y, month => 6, day => 15));
    "{$z.direction}-{$z.element}-{$z.sign}"
}

my @sixty = (1984 .. 2043).map(&triple);
say 'distinct triples in 60 consecutive years : ', @sixty.unique.elems;
say 'repeats at +60 ?                         : ', triple(1984) eq triple(2044);
say 'repeats at +30 ?                         : ', triple(1984) eq triple(2014);
say '';
say '1984 is ', triple(1984), '  — jiǎ-zǐ, the head of a cycle.';

# Output:
#     distinct triples in 60 consecutive years : 60
#     repeats at +60 ?                         : True
#     repeats at +30 ?                         : False
#     
#     1984 is yang-wood-rat  — jiǎ-zǐ, the head of a cycle.
