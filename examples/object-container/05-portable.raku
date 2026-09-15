#!/usr/bin/env rakupp
# Object::Container — Where the two engines differ
# https://raku.online/modules/object-container/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Object::Container
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Object::Container;

# an initialiser that cannot throw, and cannot recurse
my $c = Object::Container.new;
$c.register('config', sub {
    my $r = try { %( retries => 3, timeout => 30 ) };
    $r // %()
});
say 'config : ', $c.get('config').raku;
say '';
say 'an initialiser returning Nil is cached as Any and NOT retried:';
my $n = 0;
$c.register('nil', sub { $n++; Nil });
$c.get('nil'); $c.get('nil');
say '  get twice, initialiser ran : ', $n, ' time(s)';
say '';
say 'and get-instance`s double-checked-lock fast path returns while still';
say 'holding the lock — unreachable single-threaded, the same leak in a';
say 'race. Treat this container as single-threaded, or build your own.';

# Output:
#     config : ${:retries(3), :timeout(30)}
#     
#     an initialiser returning Nil is cached as Any and NOT retried:
#       get twice, initialiser ran : 1 time(s)
#     
#     and get-instance`s double-checked-lock fast path returns while still
#     holding the lock — unreachable single-threaded, the same leak in a
#     race. Treat this container as single-threaded, or build your own.
