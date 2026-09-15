#!/usr/bin/env rakupp
# Path::Canonical — The one thing to know
# https://raku.online/modules/path-canonical/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Path::Canonical
#     rakupp 02-absolute.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Path::Canonical;

for 'a/b', './a/b', '../a/b', 'a/../../b', '', '.', '..' -> $p {
    say sprintf('  %-12s -> %s', $p.raku, canon-path($p).raku);
}
say '';
say 'a relative path goes in and an absolute one comes out, rooted at /.';
say 'A programmer reaching for a "canonicalise" helper will feed it a';
say 'relative path and get back something pointing somewhere else';
say 'entirely.';
say '';
say 'and it is not idempotent-looking across shapes — /a/b/.. keeps a';
say 'trailing slash while /a/b does not, so string comparison of two';
say '"canonical" paths can disagree.';

# Output:
#       "a/b"        -> "/a/b"
#       "./a/b"      -> "/a/b"
#       "../a/b"     -> "/a/b"
#       "a/../../b"  -> "/b"
#       ""           -> "/"
#       "."          -> "/"
#       ".."         -> "/"
#     
#     a relative path goes in and an absolute one comes out, rooted at /.
#     A programmer reaching for a "canonicalise" helper will feed it a
#     relative path and get back something pointing somewhere else
#     entirely.
#     
#     and it is not idempotent-looking across shapes — /a/b/.. keeps a
#     trailing slash while /a/b does not, so string comparison of two
#     "canonical" paths can disagree.
