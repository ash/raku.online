#!/usr/bin/env rakupp
# Method::Also — What it is for
# https://raku.online/modules/method-also/#what-it-is-for
#
# Install what it needs, then run it:
#     rakupp install Method::Also
#     rakupp 01-aliases.raku
#
# Run under Raku++ 3.20.1 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Method::Also;

class Queue {
    has @!items;
    method push($x) is also<enqueue add> { @!items.push($x); self }
    method shift() is also<dequeue> { @!items.shift }
    method elems() is also<Numeric> { @!items.elems }
}

my $q = Queue.new;
$q.enqueue('a');
$q.add('b');
$q.push('c');
say $q.dequeue;
say $q.elems;
say $q + 0;

# Output:
#     a
#     2
#     2
