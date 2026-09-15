#!/usr/bin/env rakupp
# Digest::FNV — Hashing
# https://raku.online/modules/digest-fnv/#hashing
#
# Install what it needs, then run it:
#     rakupp install Digest::FNV
#     rakupp 01-fnv.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Digest::FNV :DEFAULT, :DEPRECATED;

my @v32 = '' => 0x811c9dc5, 'a' => 0xe40c292c, 'foobar' => 0xbf9cf968;
my @v64 = '' => 0xcbf29ce484222325, 'a' => 0xaf63dc4c8601ec8c,
          'foobar' => 0x85944171f73967e8;

say 'FNV-1a against the published reference vectors:';
for @v32 -> $p {
    my $g = fnv1a($p.key, :bits(32));
    say sprintf('  fnv1a(%-8s :bits(32)) = 0x%08x  expect 0x%08x  %s',
        "'{$p.key}'", $g, $p.value, $g == $p.value ?? 'ok' !! 'MISMATCH');
}
for @v64 -> $p {
    my $g = fnv1a($p.key, :bits(64));
    say sprintf('  fnv1a(%-8s :bits(64)) = 0x%016x  %s',
        "'{$p.key}'", $g, $g == $p.value ?? 'ok' !! 'MISMATCH');
}

# Output:
#     FNV-1a against the published reference vectors:
#       fnv1a(''       :bits(32)) = 0x811c9dc5  expect 0x811c9dc5  ok
#       fnv1a('a'      :bits(32)) = 0xe40c292c  expect 0xe40c292c  ok
#       fnv1a('foobar' :bits(32)) = 0xbf9cf968  expect 0xbf9cf968  ok
#       fnv1a(''       :bits(64)) = 0xcbf29ce484222325  ok
#       fnv1a('a'      :bits(64)) = 0xaf63dc4c8601ec8c  ok
#       fnv1a('foobar' :bits(64)) = 0x85944171f73967e8  ok
