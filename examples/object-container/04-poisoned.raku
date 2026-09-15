#!/usr/bin/env rakupp
# Object::Container — The one thing to know
# https://raku.online/modules/object-container/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Object::Container
#     rakupp 04-poisoned.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Object::Container;

my $c = Object::Container.new;
my $calls = 0;
$c.register('bad', sub { $calls++; die 'initializer failed' });

my $first = try $c.get('bad');
say 'first get     : ', $! ?? 'threw — ' ~ $!.message !! 'returned';
say 'calls so far  : ', $calls;
say '';
say 'get-instance does  $!lock.lock; … $!instance = $!initializer(); …';
say '$!lock.unlock  with no LEAVE and no .protect — so the throw skips';
say 'the unlock.';
say '';
say 'the SAME thread can still get through, because Lock is reentrant';
say 'per-thread:';
my $second = try $c.get('bad');
say '  second get on this thread : ', $! ?? 'threw again' !! 'returned';
say '  calls now                 : ', $calls;
say '';
say 'a SECOND thread blocks forever. And each entry has its own Lock, so';
say 'other keys keep working — which makes it far harder to diagnose:';
$c.register('ok', sub { 'healthy' });
say '  a different key still works : ', $c.get('ok').raku;
say '';
say 'wrap your initialisers so they cannot throw.';

# Output:
#     first get     : threw — initializer failed
#     calls so far  : 1
#     
#     get-instance does  $!lock.lock; … $!instance = $!initializer(); …
#     $!lock.unlock  with no LEAVE and no .protect — so the throw skips
#     the unlock.
#     
#     the SAME thread can still get through, because Lock is reentrant
#     per-thread:
#       second get on this thread : threw again
#       calls now                 : 2
#     
#     a SECOND thread blocks forever. And each entry has its own Lock, so
#     other keys keep working — which makes it far harder to diagnose:
#       a different key still works : "healthy"
#     
#     wrap your initialisers so they cannot throw.
