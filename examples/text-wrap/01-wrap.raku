#!/usr/bin/env rakupp
# Text::Wrap — Folding
# https://raku.online/modules/text-wrap/#folding
#
# Install what it needs, then run it:
#     rakupp install Text::Wrap
#     rakupp 01-wrap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Wrap;

my $t = 'The quick brown fox jumps over the lazy dog and keeps running far away from the farm';
say wrap-text($t, :width(32));
say wrap-text($t, :width(32), :prefix('> '));
say wrap-text("first paragraph here\n\nsecond one", :width(12));
say wrap-text('supercalifragilisticexpialidocious word', :width(10), :hard-wrap);

# Output:
#     The quick brown fox jumps over
#     the lazy dog and keeps running
#     far away from the farm
#     > The quick brown fox jumps over
#     > the lazy dog and keeps running
#     > far away from the farm
#     first
#     paragraph
#     here
#     
#     second one
#     supercalif
#     ragilistic
#     expialidoc
#     ious word
