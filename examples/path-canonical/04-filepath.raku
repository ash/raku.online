#!/usr/bin/env rakupp
# Path::Canonical — Where the two engines differ
# https://raku.online/modules/path-canonical/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install Path::Canonical
#     rakupp 04-filepath.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Path::Canonical;

say 'the distribution exports a second sub with a Windows branch:';
for '/a/b/../c', 'C:\\tmp\\x', 'a\\b' -> $p {
    say sprintf('  %-14s canon-path=%-14s canon-filepath=%s',
                $p.raku, canon-path($p).raku, canon-filepath($p).raku);
}
say '';
say 'off Windows that branch is unreachable, so canon-filepath is a';
say 'slower alias for canon-path — including for the backslash cases,';
say 'which it makes no attempt to handle.';
say '';
say 'the unit also declares an empty `class Path::Canonical` with no';
say 'members; the two subs are the whole distribution.';

# Output:
#     the distribution exports a second sub with a Windows branch:
#       "/a/b/../c"    canon-path="/a/c"         canon-filepath="/a/c"
#       "C:\\tmp\\x"   canon-path="/C:\\tmp\\x"  canon-filepath="/C:\\tmp\\x"
#       "a\\b"         canon-path="/a\\b"        canon-filepath="/a\\b"
#     
#     off Windows that branch is unreachable, so canon-filepath is a
#     slower alias for canon-path — including for the backslash cases,
#     which it makes no attempt to handle.
#     
#     the unit also declares an empty `class Path::Canonical` with no
#     members; the two subs are the whole distribution.
