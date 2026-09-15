---
name: MessageStream
version: 0.2.0
auth: zef:markldevine
kind: Distribution · messaging
summary: A role giving your class a one-to-many message bus — where
  subscribing twice leaks a tap you cannot see or remove.
status: divergent
suite: no test files, so trivially green
tested: 2026-09-15
license: Artistic-2.0
depends: JSON::Marshal, JSON::Unmarshal
raku-land: https://raku.land/zef:markldevine/MessageStream
source: https://github.com/markldevine/raku-MessageStream.git
---

## What it is for

One object, several interested parties. Compose this role into your class and
it gains a `Supplier`; `post` marshals a payload plus arbitrary named options
to JSON and emits them, and `subscribe(:destination<log>)` routes every
message to *your* method named `log-receive`.

Destinations are named, so one object can fan out to several handlers it
implements itself.

## Publishing and subscribing

```raku name="basics"
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
```

```output
taps before subscribe : ().Seq
taps after subscribe  : ("log",).Seq
delivered             : ["hello level=info,n=3"]
after unsubscribe     : ["hello level=info,n=3"]
```

`subscribe` checks that the method exists and refuses otherwise:

```raku name="missing"
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
```

```output
subscribe to an unimplemented destination -> Unable to subscribe: First implement method nope-receive (MessageStream::Message:D $message) in your code

the supply is LIVE, so anything posted before subscribe is gone:
  the early message arrived ? no
```

## The payload rules are not the option rules

```raku name="payload"
use MessageStream;

class Bus does MessageStream {
    has $.last is rw;
    method log-receive(MessageStream::Message:D $m) {
        $!last = ($m.payload, $m.options);
    }
}
my $b = Bus.new;
$b.subscribe(destination => 'log');

for 'hi', 42, 0, False, '', [1, 2, 3], [], (1, 2) -> $p {
    $b.post($p);
    my $got = $b.last[0];
    say sprintf('  post(%-12s) -> %-22s %s', $p.raku,
                ($got ~~ Positional ?? '(' ~ $got.map(*.raku).join(', ') ~ ')'
                                    !! $got.raku),
                $got.WHAT.^name);
}
say '';
say 'every FALSY payload becomes the empty string — the guard is a bare';
say '`if $payload`. Posting a zero count or an empty batch is data loss.';
say '';
say 'and a LIST payload has every element stringified while a scalar one';
say 'does not. Named options are untouched:';
$b.post([1, 2], l => [1, 2]);
say '  payload [1,2] -> ', $b.last[0].map(*.raku).join(', ');
say '  option  [1,2] -> ', $b.last[1]<l>.map(*.raku).join(', ');
```

```output
  post("hi"        ) -> "hi"                   Str
  post(42          ) -> 42                     Int
  post(0           ) -> ""                     Str
  post(Bool::False ) -> ""                     Str
  post(""          ) -> ""                     Str
  post($[1, 2, 3]  ) -> ("1", "2", "3")        Array
  post($[]         ) -> ""                     Str
  post($(1, 2)     ) -> ("1", "2")             Array

every FALSY payload becomes the empty string — the guard is a bare
`if $payload`. Posting a zero count or an empty batch is data loss.

and a LIST payload has every element stringified while a scalar one
does not. Named options are untouched:
  payload [1,2] -> "1", "2"
  option  [1,2] -> 1, 2
```

## The one thing to know

`subscribe` is not idempotent. Subscribing the same destination twice leaks a
second, permanently-live tap that you cannot see and cannot remove.

```raku name="leak"
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
```

```output
taps reports : ("a",).Seq   <- exactly one
deliveries   : ["a:one", "a:one"]   <- twice

after unsubscribe : ["a:two"]   <- still receiving

subscribe does  %!taps{$destination} = $!supply.tap: {…}  — it
overwrites the stored HANDLE without closing the previous tap, which
stays attached to the supply forever. There is no API that reaches it.

a reconnect loop, or a re-subscribe after a config reload, doubles
your side effects permanently and the object reports nothing wrong.
Unsubscribe before you subscribe again.
```

## Delivery is synchronous

```raku name="synchronous"
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
```

```output
trace : ["before post", "receive:one", "after post"]

the receiver runs INSIDE post, on the posting thread, inside
$!lock.protect. A slow subscriber blocks the publisher and every
other publisher on that instance.

each INSTANCE has its own Supplier, so two objects of the same class
do not see each other`s messages.
```

## Where the two engines differ

Two Raku++ lenities that hide real bugs in this module. An exception thrown
inside a `Supply` tap handler is swallowed there and propagates out of `emit`
on Rakudo; and `Lock::Async.protect` is reentrant on Raku++ and correctly
blocks on Rakudo, so a subscriber that posts again deadlocks on one engine and
returns on the other.

```raku name="portable"
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
```

```output
so on Raku++ a subscriber`s crash vanishes and a re-entrant post
succeeds; on Rakudo the crash reaches your post() call and the
re-entrant post deadlocks.

write subscribers that cannot throw and do not post:
  delivered : ["safe"]

and note .taps is declared --> Tap and in fact returns a Hash[Tap] —
read its keys, not the object.
```
