#!/usr/bin/env rakupp
# MessageStream — Delivery is synchronous
# https://raku.online/modules/messagestream/#delivery-is-synchronous
#
# Install what it needs, then run it:
#     rakupp install MessageStream
#     rakupp 05-synchronous.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use MessageStream;

class Bus does MessageStream {
    has @.trace;
    method log-receive(MessageStream::Message:D $m) { @!trace.push('receive:' ~ $m.payload) }
}
my $b = Bus.new;
$b.subscribe(destination => 'log');

$b.trace.push('before post');
$b.post('one');
$b.trace.push('after post');
say 'trace : ', $b.trace.raku;
say '';
say 'the receiver runs INSIDE post, on the posting thread, inside';
say '$!lock.protect. A slow subscriber blocks the publisher and every';
say 'other publisher on that instance.';
say '';
say 'each INSTANCE has its own Supplier, so two objects of the same class';
say 'do not see each other`s messages.';

# Output:
#     trace : ["before post", "receive:one", "after post"]
#     
#     the receiver runs INSIDE post, on the posting thread, inside
#     $!lock.protect. A slow subscriber blocks the publisher and every
#     other publisher on that instance.
#     
#     each INSTANCE has its own Supplier, so two objects of the same class
#     do not see each other`s messages.
