#!/usr/bin/env rakupp
# Lazy::Static — Under contention
# https://raku.online/modules/lazy-static/#under-contention
#
# Install what it needs, then run it:
#     rakupp install Lazy::Static
#     rakupp 02-threads.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lazy::Static;

my atomicint $calls = 0;
my &value = lazy-static -> { atomic-fetch-inc($calls); sleep 0.2; 'computed-once' };

my @results = await (^16).map: { start value() };

say 'sixteen concurrent callers';
say '  distinct results : ', @results.unique.sort.join(',');
say '  result count     : ', @results.elems;
say '  generator calls  : ', $calls;

# Output:
#     sixteen concurrent callers
#       distinct results : computed-once
#       result count     : 16
#       generator calls  : 1
