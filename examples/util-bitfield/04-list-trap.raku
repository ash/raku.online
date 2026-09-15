#!/usr/bin/env rakupp
# Util::Bitfield — The one thing to know
# https://raku.online/modules/util-bitfield/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Util::Bitfield
#     rakupp 04-list-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Util::Bitfield;

my $word = 0xAC35F096;

say 'extract-bits-list(word, 4) asks for 4-bit fields:';
my @l = extract-bits-list($word, 4).List;
say '  ', @l.raku;
say '  largest value : ', @l.max, '   but a 4-bit field holds 0..15';
say '  values over 15: ', @l.grep(* > 15).List.raku;
say '';
say 'every result is really a SIX-bit field, whatever you ask for:';
for 4, 8, 16 -> $bits {
    my $n = 32 div $bits;
    my @pred = (^$n).map({ ($word +> (32 - $_ * $bits - 6)) +& 0b111111 });
    my @got  = extract-bits-list($word, $bits).List;
    say sprintf('  bits=%-2d  got=%-30s  six-bit prediction matches: %s',
        $bits, @got.raku, @got eqv @pred);
}
say '';
say 'the honest answer, from extract-bits itself:';
for 4, 8, 16 -> $bits {
    my $n = 32 div $bits;
    say sprintf('  bits=%-2d  %s', $bits,
        (^$n).map({ extract-bits($word, $bits, $_ * $bits, 32) }).List.raku);
}

# Output:
#     extract-bits-list(word, 4) asks for 4-bit fields:
#       [43, 48, 13, 23, 60, 2, 37, 24]
#       largest value : 60   but a 4-bit field holds 0..15
#       values over 15: (43, 48, 23, 60, 37, 24)
#     
#     every result is really a SIX-bit field, whatever you ask for:
#       bits=4   got=[43, 48, 13, 23, 60, 2, 37, 24]  six-bit prediction matches: True
#       bits=8   got=[43, 13, 60, 37]                six-bit prediction matches: True
#       bits=16  got=[43, 60]                        six-bit prediction matches: True
#     
#     the honest answer, from extract-bits itself:
#       bits=4   (10, 12, 3, 5, 15, 0, 9, 6)
#       bits=8   (172, 53, 240, 150)
#       bits=16  (44085, 61590)
