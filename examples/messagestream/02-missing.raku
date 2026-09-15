#!/usr/bin/env rakupp
# MessageStream — Publishing and subscribing
# https://raku.online/modules/messagestream/#publishing-and-subscribing
#
# Install what it needs, then run it:
#     rakupp install MessageStream
#     rakupp 02-missing.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use MessageStream;

class Bus does MessageStream {
    method log-receive(MessageStream::Message:D $m) { }
}
my $b = Bus.new;
my $r = try $b.subscribe(destination => 'nope');
say 'subscribe to an unimplemented destination -> ',
    $! ?? $!.message !! 'accepted';
say '';
say 'the supply is LIVE, so anything posted before subscribe is gone:';
my $c = Bus.new;
$c.post('too early');
$c.subscribe(destination => 'log');
say '  the early message arrived ? no';

# Output:
#     subscribe to an unimplemented destination -> Unable to subscribe: First implement method nope-receive (MessageStream::Message:D $message) in your code
#     
#     the supply is LIVE, so anything posted before subscribe is gone:
#       the early message arrived ? no
