#!/usr/bin/env rakupp
# MessageStream — Where the two engines differ
# https://raku.online/modules/messagestream/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install MessageStream
#     rakupp 06-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use MessageStream;

say 'so on Raku++ a subscriber`s crash vanishes and a re-entrant post';
say 'succeeds; on Rakudo the crash reaches your post() call and the';
say 're-entrant post deadlocks.';
say '';
say 'write subscribers that cannot throw and do not post:';
class Bus does MessageStream {
    has @.seen;
    method log-receive(MessageStream::Message:D $m) {
        my $r = try { @!seen.push($m.payload); True };
        # swallow deliberately, and never post from in here
    }
}
my $b = Bus.new;
$b.subscribe(destination => 'log');
$b.post('safe');
say '  delivered : ', $b.seen.raku;
say '';
say 'and note .taps is declared --> Tap and in fact returns a Hash[Tap] —';
say 'read its keys, not the object.';

# Output:
#     so on Raku++ a subscriber`s crash vanishes and a re-entrant post
#     succeeds; on Rakudo the crash reaches your post() call and the
#     re-entrant post deadlocks.
#     
#     write subscribers that cannot throw and do not post:
#       delivered : ["safe"]
#     
#     and note .taps is declared --> Tap and in fact returns a Hash[Tap] —
#     read its keys, not the object.
