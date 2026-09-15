#!/usr/bin/env rakupp
# Text::T9 — The one thing to know
# https://raku.online/modules/text-t9/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Text::T9
#     rakupp 04-seq.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::T9;

my @words = <good home gone>;

say 'the safe shape — cache it once:';
my @matches = t9('4663', @words).List;
say '  matches : ', @matches.elems;
say '  they are: ', @matches.join(' ');
say '  again   : ', @matches.join(' ');
say '';
say 'the unsafe one:';
say '  my $seq = t9("4663", @words);';
say '  say $seq.elems;      # walks it';
say '  say $seq.join(" ");  # X::Seq::Consumed on Rakudo';
say '';
say 'anything that touches the result twice — count then iterate, log then';
say 'use — passes on Raku++ and breaks on Rakudo. Call .List or .cache';
say 'once and work from that.';

# Output:
#     the safe shape — cache it once:
#       matches : 3
#       they are: good home gone
#       again   : good home gone
#     
#     the unsafe one:
#       my $seq = t9("4663", @words);
#       say $seq.elems;      # walks it
#       say $seq.join(" ");  # X::Seq::Consumed on Rakudo
#     
#     anything that touches the result twice — count then iterate, log then
#     use — passes on Raku++ and breaks on Rakudo. Call .List or .cache
#     once and work from that.
