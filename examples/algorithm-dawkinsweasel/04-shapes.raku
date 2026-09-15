#!/usr/bin/env rakupp
# Algorithm::DawkinsWeasel — Two API shapes
# https://raku.online/modules/algorithm-dawkinsweasel/#two-api-shapes
#
# Install what it needs, then run it:
#     rakupp install Algorithm::DawkinsWeasel
#     rakupp 04-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::DawkinsWeasel;

say 'has Str @.target-phrase is a public ARRAY attribute, but an explicit';
say '`method target-phrase` shadows the generated accessor — so it returns';
say 'a Str and the array form is unreachable:';
my $w = Algorithm::DawkinsWeasel.new(target-phrase => 'WEASEL');
say '  .target-phrase.WHAT : ', $w.target-phrase.WHAT.^name;
say '';
say 'mutation-threshold is typed Rat, so a Num or an Int is refused:';
for 1/20, 0.05e0, 0 -> $m {
    my $r = try Algorithm::DawkinsWeasel.new(target-phrase => 'AB',
                                             mutation-threshold => $m);
    say sprintf('  %-10s (%s) -> %s', $m.raku, $m.WHAT.^name,
                $! ?? 'refused' !! 'accepted');
}
say '';
say '.evolution MUTATES the receiver and can be called again — a second';
say 'walk of an already-solved object adds exactly one more generation.';

# Output:
#     has Str @.target-phrase is a public ARRAY attribute, but an explicit
#     `method target-phrase` shadows the generated accessor — so it returns
#     a Str and the array form is unreachable:
#       .target-phrase.WHAT : Str
#     
#     mutation-threshold is typed Rat, so a Num or an Int is refused:
#       0.05       (Rat) -> accepted
#       0.05e0     (Num) -> refused
#       0          (Int) -> refused
#     
#     .evolution MUTATES the receiver and can be called again — a second
#     walk of an already-solved object adds exactly one more generation.
