#!/usr/bin/env rakupp
# TinyID — What it refuses
# https://raku.online/modules/tinyid/#what-it-refuses
#
# Install what it needs, then run it:
#     rakupp install TinyID
#     rakupp 04-refusals.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TinyID;

for 'aba', 'a', '' -> $key {
    my $r = try TinyID.new(:$key);
    say sprintf('  new(key => %-8s) -> %s', $key.raku, $! ?? 'refused' !! 'built');
}
say '';
say 'the key must have at least two DISTINCT characters — the constraint';
say 'is  .chars >= 2 and not /(.).*$0/';
say '';
my $t = TinyID.new(key => 'cbad');
for -1, 'z' -> $bad {
    my $r = try $bad ~~ Int ?? $t.encode($bad) !! $t.decode($bad);
    say sprintf('  %-12s -> %s',
                $bad ~~ Int ?? "encode($bad)" !! "decode({$bad.raku})",
                $! ?? 'refused' !! $r);
}
say '';
say 'a character outside the key, and a negative id, are both binding';
say 'failures rather than wrong answers.';

# Output:
#       new(key => "aba"   ) -> refused
#       new(key => "a"     ) -> refused
#       new(key => ""      ) -> refused
#     
#     the key must have at least two DISTINCT characters — the constraint
#     is  .chars >= 2 and not /(.).*$0/
#     
#       encode(-1)   -> refused
#       decode("z")  -> refused
#     
#     a character outside the key, and a negative id, are both binding
#     failures rather than wrong answers.
