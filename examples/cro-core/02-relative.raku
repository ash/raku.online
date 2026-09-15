#!/usr/bin/env rakupp
# Cro::Core — Resolving a relative reference
# https://raku.online/modules/cro-core/#resolving-a-relative-reference
#
# Install what it needs, then run it:
#     rakupp install Cro::Core
#     rakupp 02-relative.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Cro::Uri;

my $base = Cro::Uri.parse('http://a/b/c/d;p?q');

# The reference-resolution examples from RFC 3986 section 5.4.
for <g ./g g/ /g //g ?y g?y #s g#s . ./ .. ../ ../.. ../../g> -> $ref {
    say sprintf('%-8s -> %s', $ref, $base.add($ref).Str);
}

# Output:
#     g        -> http://a/b/c/g
#     ./g      -> http://a/b/c/g
#     g/       -> http://a/b/c/g/
#     /g       -> http://a/g
#     //g      -> http://g
#     ?y       -> http://a/b/c/d;p?y
#     g?y      -> http://a/b/c/g?y
#     #s       -> http://a/b/c/d;p?q#s
#     g#s      -> http://a/b/c/g#s
#     .        -> http://a/b/c/
#     ./       -> http://a/b/c/
#     ..       -> http://a/b/
#     ../      -> http://a/b/
#     ../..    -> http://a/
#     ../../g  -> http://a/g
