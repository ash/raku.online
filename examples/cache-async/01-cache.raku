#!/usr/bin/env rakupp
# Cache::Async — Caching
# https://raku.online/modules/cache-async/#caching
#
# Install what it needs, then run it:
#     rakupp install Cache::Async
#     rakupp 01-cache.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Cache::Async;

my atomicint $calls = 0;
my $cache = Cache::Async.new(
    max-size => 10,
    producer => sub ($k, *@extra) {
        atomic-fetch-inc($calls);
        "value-for-$k" ~ (@extra ?? '+' ~ @extra.join(',') !! '')
    },
);

say 'get returns a : ', $cache.get('a').^name;
say '';
say 'a       -> ', await $cache.get('a');
say 'a again -> ', await $cache.get('a');
say 'b       -> ', await $cache.get('b');
say 'extra arguments reach the producer : ', await $cache.get('c', 1, 2);
say '';
say 'producer calls : ', atomic-fetch($calls);
say 'hits, misses   : ', $cache.hits-misses.raku;

# Output:
#     get returns a : Promise
#     
#     a       -> value-for-a
#     a again -> value-for-a
#     b       -> value-for-b
#     extra arguments reach the producer : value-for-c+1,2
#     
#     producer calls : 3
#     hits, misses   : (2, 3)
