#!/usr/bin/env rakupp
# Cache::Async — The one thing to know
# https://raku.online/modules/cache-async/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Cache::Async
#     rakupp 04-poison-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Cache::Async;

my atomicint $calls = 0;
my $cache = Cache::Async.new(producer => sub ($k) {
    my $n = atomic-inc-fetch($calls);
    die 'transient outage' if $n == 1;      # fails once, then works
    "value-$n"
});

for 1 .. 4 -> $i {
    my $p = $cache.get('k');
    await Promise.anyof($p, Promise.in(5));
    say "attempt $i : ", $p.status;
}
say 'producer was called ', atomic-fetch($calls), ' time(s) in four attempts';
say '';
$cache.remove('k');
my $p = $cache.get('k');
await Promise.anyof($p, Promise.in(5));
say 'after remove("k"), the next get : ', $p.status,
    ' -> ', $p.status ~~ Kept ?? $p.result !! 'still broken';

# Output:
#     attempt 1 : Broken
#     attempt 2 : Broken
#     attempt 3 : Broken
#     attempt 4 : Broken
#     producer was called 1 time(s) in four attempts
#     
#     after remove("k"), the next get : Kept -> value-2
