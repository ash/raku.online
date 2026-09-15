#!/usr/bin/env rakupp
# Algorithm::DawkinsWeasel — Things that will not terminate
# https://raku.online/modules/algorithm-dawkinsweasel/#things-that-will-not-terminate
#
# Install what it needs, then run it:
#     rakupp install Algorithm::DawkinsWeasel
#     rakupp 03-termination.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::DawkinsWeasel;

say 'the charset is A..Z plus space. A target containing ANYTHING else —';
say 'a lowercase letter, a digit, punctuation — can never be reached, and';
say '.evolution never ends.';
say '';
say 'and copies => 0 produces no trial at all, so hi-score can never';
say 'rise and the sequence is infinite:';
say '  (Raku++ silently caps an infinite gather at 2**20 elements;';
say '   Rakudo runs until you kill it.)';
say '';
say 'check the target before you start:';
sub weasel(Str $target, *%opts) {
    die "target must be A..Z and spaces only: {$target.raku}"
        unless $target ~~ /^ <[A..Z ]>* $/;
    Algorithm::DawkinsWeasel.new(target-phrase => $target, |%opts)
}
for 'ME THINKS', 'methinks' -> $t {
    my $r = try weasel($t, copies => 10);
    say sprintf('  %-12s -> %s', $t.raku, $! ?? 'refused' !! 'ok');
}
say '';
say 'an empty target terminates immediately:';
my $e = Algorithm::DawkinsWeasel.new(target-phrase => '');
say '  evolution elems : ', $e.evolution.elems;

# Output:
#     the charset is A..Z plus space. A target containing ANYTHING else —
#     a lowercase letter, a digit, punctuation — can never be reached, and
#     .evolution never ends.
#     
#     and copies => 0 produces no trial at all, so hi-score can never
#     rise and the sequence is infinite:
#       (Raku++ silently caps an infinite gather at 2**20 elements;
#        Rakudo runs until you kill it.)
#     
#     check the target before you start:
#       "ME THINKS"  -> refused
#       "methinks"   -> refused
#     
#     an empty target terminates immediately:
#       evolution elems : 2
