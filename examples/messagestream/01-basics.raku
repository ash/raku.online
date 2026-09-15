#!/usr/bin/env rakupp
# MessageStream — Publishing and subscribing
# https://raku.online/modules/messagestream/#publishing-and-subscribing
#
# Install what it needs, then run it:
#     rakupp install MessageStream
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use MessageStream;

class Bus does MessageStream {
    has @.seen;
    method log-receive(MessageStream::Message:D $m) {
        @!seen.push("{$m.payload} " ~ $m.options.map({ .key ~ '=' ~ .value }).sort.join(','));
    }
}

my $b = Bus.new;
say 'taps before subscribe : ', $b.taps.keys.sort.raku;
$b.subscribe(destination => 'log');
say 'taps after subscribe  : ', $b.taps.keys.sort.raku;

$b.post('hello', level => 'info', n => 3);
say 'delivered             : ', $b.seen.raku;

$b.unsubscribe(destination => 'log');
$b.post('after unsubscribe');
say 'after unsubscribe     : ', $b.seen.raku;

# Output:
#     taps before subscribe : ().Seq
#     taps after subscribe  : ("log",).Seq
#     delivered             : ["hello level=info,n=3"]
#     after unsubscribe     : ["hello level=info,n=3"]
