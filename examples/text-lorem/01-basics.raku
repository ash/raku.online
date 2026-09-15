#!/usr/bin/env rakupp
# Text::Lorem — The three methods
# https://raku.online/modules/text-lorem/#the-three-methods
#
# Install what it needs, then run it:
#     rakupp install Text::Lorem
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Lorem;

my $l = Text::Lorem.new;

my $w = $l.words(5);
say 'words(5)      : ', $w.words.elems, ' words, ends with a full stop? ', $w.ends-with('.');
say '                capitalised? ', ($w ~~ /^<:Lu>/).so;

my $s = $l.sentences(3);
say 'sentences(3)  : ', $s.split('. ').elems, ' sentences';
say '                every sentence Titlecased? ',
    $s.split('. ').map({ so /^<:Lu>/ }).all.so;

my $p = $l.paragraphs(2);
say 'paragraphs(2) : ', $p.split("\n\n").elems, ' paragraphs, separated by a blank line';

# Output:
#     words(5)      : 5 words, ends with a full stop? True
#                     capitalised? False
#     sentences(3)  : 3 sentences
#                     every sentence Titlecased? True
#     paragraphs(2) : 2 paragraphs, separated by a blank line
