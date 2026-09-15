#!/usr/bin/env rakupp
# Cache::Async — The rest of the interface
# https://raku.online/modules/cache-async/#the-rest-of-the-interface
#
# Install what it needs, then run it:
#     rakupp install Cache::Async
#     rakupp 02-interface.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Cache::Async;

my $cache = Cache::Async.new(producer => sub ($k) { $k.uc });

await $cache.get('a');
say 'get-if-present("a")    : ', $cache.get-if-present('a').raku;
say 'get-if-present("nope") : ', $cache.get-if-present('nope').raku;
say '';
$cache.put('warm', 'preloaded');
say 'put then get-if-present : ', $cache.get-if-present('warm').raku;
$cache.remove('a');
say 'after remove("a")       : ', $cache.get-if-present('a').raku;
$cache.clear;
say 'after clear             : ', $cache.get-if-present('warm').raku;
say '';
say 'defaults : max-size=', $cache.max-size,
    ' cache-undefined=', $cache.cache-undefined,
    ' max-age=', $cache.max-age.raku;

# Output:
#     get-if-present("a")    : "A"
#     get-if-present("nope") : Nil
#     
#     put then get-if-present : "preloaded"
#     after remove("a")       : Nil
#     after clear             : Nil
#     
#     defaults : max-size=1024 cache-undefined=True max-age=Any
