#!/usr/bin/env rakupp
# Scientist — When they disagree
# https://raku.online/modules/scientist/#when-they-disagree
#
# Install what it needs, then run it:
#     rakupp install Scientist
#     rakupp 02-mismatch.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Scientist;

my $s = Scientist.new(
    experiment => 'disagree',
    use        => sub { 'old' },
    try        => sub { 'new' },
);
say 'run returned : ', $s.run.raku, '   <- the control`s value';
say 'mismatched   : ', $s.result<mismatched>;
say '';
say 'and note what is NOT recorded — neither value:';
say '  result keys : ', $s.result.keys.sort.join(', ');
say '';
my $t = Scientist.new(
    experiment => 'candidate throws',
    use        => sub { 'old' },
    try        => sub { die 'boom' },
);
say 'a candidate that THROWS:';
say '  run survived : ', ($t.run.defined ?? 'yes' !! 'no');
say '  returned     : ', $t.run.raku;
say '  mismatched   : ', $t.result<mismatched>;
say '';
say 'the exception is swallowed by an inner try, $candidate stays';
say 'undefined, mismatched becomes True, and nothing anywhere records';
say 'that an exception happened. A candidate that always throws is';
say 'indistinguishable from one that always returns the wrong answer.';
say '';
say 'the CONTROL`s exceptions propagate to your caller, which is right.';

# Output:
#     run returned : "old"   <- the control`s value
#     mismatched   : True
#     
#     and note what is NOT recorded — neither value:
#       result keys : candidate, context, control, experiment, mismatched
#     
#     a candidate that THROWS:
#       run survived : yes
#       returned     : "old"
#       mismatched   : True
#     
#     the exception is swallowed by an inner try, $candidate stays
#     undefined, mismatched becomes True, and nothing anywhere records
#     that an exception happened. A candidate that always throws is
#     indistinguishable from one that always returns the wrong answer.
#     
#     the CONTROL`s exceptions propagate to your caller, which is right.
