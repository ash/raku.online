#!/usr/bin/env rakupp
# UNIX::Privileges — When the lookup fails
# https://raku.online/modules/unix-privileges/#when-the-lookup-fails
#
# Install what it needs, then run it:
#     rakupp install UNIX::Privileges
#     rakupp 03-miss.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use UNIX::Privileges :USER;

for 'nosuchuser-xyzzy', 'nosuchgroup-xyzzy' -> $n {
    my $r = try $n.starts-with('nosuchuser') ?? userinfo($n) !! groupinfo($n);
    say sprintf('%-20s -> %s', $n, $! ?? $!.message !! 'found');
}

# Output:
#     nosuchuser-xyzzy     -> fatal: could not get user info: no such user
#     nosuchgroup-xyzzy    -> fatal: could not get user info: no such user
