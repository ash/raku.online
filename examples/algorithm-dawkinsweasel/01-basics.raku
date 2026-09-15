#!/usr/bin/env rakupp
# Algorithm::DawkinsWeasel — Running it
# https://raku.online/modules/algorithm-dawkinsweasel/#running-it
#
# Install what it needs, then run it:
#     rakupp install Algorithm::DawkinsWeasel
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::DawkinsWeasel;

my $w = Algorithm::DawkinsWeasel.new(
    target-phrase      => 'WEASEL',
    mutation-threshold => 1/20,
    copies             => 30,
);
say 'target             : ', $w.target-phrase;
say 'mutation-threshold : ', $w.mutation-threshold;
say 'copies             : ', $w.copies;
say '';
say 'before evolving:';
say '  count            : ', $w.count;
say '  hi-score         : ', $w.hi-score;
say '  current-phrase   : ', $w.current-phrase.chars, ' characters';
my $charset = set(flat 'A'..'Z', ' ');
say '  drawn from A..Z and space : ',
    so $w.current-phrase.comb.all (elem) $charset;
say '';
# walk until it converges, bounded so the page cannot hang
my $steps = 0;
for $w.evolution { last if ++$steps > 5000 }
say 'after walking the sequence:';
say '  solved           : ', $w.current-phrase eq 'WEASEL';
say '  generations run  : ', $w.count > 0;
say '  final score      : ', $w.hi-score == 'WEASEL'.chars;

# Output:
#     target             : WEASEL
#     mutation-threshold : 0.05
#     copies             : 30
#     
#     before evolving:
#       count            : 0
#       hi-score         : 0
#       current-phrase   : 6 characters
#       drawn from A..Z and space : True
#     
#     after walking the sequence:
#       solved           : True
#       generations run  : True
#       final score      : True
