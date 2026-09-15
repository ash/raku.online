#!/usr/bin/env rakupp
# MessageStream — The one thing to know
# https://raku.online/modules/messagestream/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install MessageStream
#     rakupp 04-leak.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use MessageStream;

class Bus does MessageStream {
    has @.seen;
    method a-receive(MessageStream::Message:D $m) { @!seen.push('a:' ~ $m.payload) }
}

my $b = Bus.new;
$b.subscribe(destination => 'a');
$b.subscribe(destination => 'a');        # again
say 'taps reports : ', $b.taps.keys.sort.raku, '   <- exactly one';
$b.post('one');
say 'deliveries   : ', $b.seen.raku,   '   <- twice';
say '';
$b.seen = [];
$b.unsubscribe(destination => 'a');
$b.post('two');
say 'after unsubscribe : ', $b.seen.raku, '   <- still receiving';
say '';
say 'subscribe does  %!taps{$destination} = $!supply.tap: {…}  — it';
say 'overwrites the stored HANDLE without closing the previous tap, which';
say 'stays attached to the supply forever. There is no API that reaches it.';
say '';
say 'a reconnect loop, or a re-subscribe after a config reload, doubles';
say 'your side effects permanently and the object reports nothing wrong.';
say 'Unsubscribe before you subscribe again.';

# Output:
#     taps reports : ("a",).Seq   <- exactly one
#     deliveries   : ["a:one", "a:one"]   <- twice
#     
#     after unsubscribe : ["a:two"]   <- still receiving
#     
#     subscribe does  %!taps{$destination} = $!supply.tap: {…}  — it
#     overwrites the stored HANDLE without closing the previous tap, which
#     stays attached to the supply forever. There is no API that reaches it.
#     
#     a reconnect loop, or a re-subscribe after a config reload, doubles
#     your side effects permanently and the object reports nothing wrong.
#     Unsubscribe before you subscribe again.
