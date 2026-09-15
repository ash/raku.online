#!/usr/bin/env rakupp
# Path::Canonical — Tidying
# https://raku.online/modules/path-canonical/#tidying
#
# Install what it needs, then run it:
#     rakupp install Path::Canonical
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Path::Canonical;

for '/a/b/c', '/a/./b', '/a/b/../c', '/a//b', '///a/b',
    '/a/b/', '/a/b/.', '/a/b/..', '/..', '/' -> $p {
    say sprintf('  %-12s -> %s', $p.raku, canon-path($p).raku);
}

# Output:
#       "/a/b/c"     -> "/a/b/c"
#       "/a/./b"     -> "/a/b"
#       "/a/b/../c"  -> "/a/c"
#       "/a//b"      -> "/a/b"
#       "///a/b"     -> "/a/b"
#       "/a/b/"      -> "/a/b/"
#       "/a/b/."     -> "/a/b/"
#       "/a/b/.."    -> "/a/"
#       "/.."        -> "/"
#       "/"          -> "/"
