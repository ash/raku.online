#!/usr/bin/env rakupp
# Text::BorderedBlock — The one thing to know
# https://raku.online/modules/text-borderedblock/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Text::BorderedBlock
#     rakupp 03-width-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::BorderedBlock;

use Terminal::ANSIColor;
my $coloured = colored('red text', 'red');
say 'the coloured string is ', $coloured.chars, ' characters long';
say Text::BorderedBlock.new(content => $coloured, minimum-width => 12)
    .render.subst(/ \e '[' <[0..9;]>* 'm' /, '', :g);
say '';
my $cjk = "\c[CJK UNIFIED IDEOGRAPH-6F22]\c[CJK UNIFIED IDEOGRAPH-5B57]";
say Text::BorderedBlock.new(content => "abcd\n$cjk", minimum-width => 10).render;

# Output:
#     the coloured string is 17 characters long
#     ┏━━━━━━━━━━━━┓
#     ┃red text    ┃
#     ┗━━━━━━━━━━━━┛
#     
#     ┏━━━━━━━━━━┓
#     ┃abcd      ┃
#     ┃漢字        ┃
#     ┗━━━━━━━━━━┛
