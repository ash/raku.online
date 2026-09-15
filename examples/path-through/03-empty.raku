#!/usr/bin/env rakupp
# Path::Through — Over-popping
# https://raku.online/modules/path-through/#over-popping
#
# Install what it needs, then run it:
#     rakupp install Path::Through
#     rakupp 03-empty.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Path::Through;

say 'popping a bare filename, or more parts than there are, produces the';
say 'EMPTY path — which is a very different thing from an error:';
my $r = try pop('file'.IO);
say '  pop("file".IO) -> engine-dependent: an empty path, or a refusal';
say '';
say 'Raku++ hands you "".IO, which stringifies to "" and will resolve';
say 'against the current directory; Rakudo refuses to build such a path';
say 'at all. Guard the part count yourself and neither can reach you:';
sub safe-pop(IO::Path $p, Int $n = 1) {
    my @parts = $p.Str.split('/').grep(*.chars);
    die "cannot drop $n of {+@parts} parts" if $n >= @parts;
    pop($p, parts => $n)
}
for 1, 3 -> $n {
    my $x = try safe-pop('a/b/c'.IO, $n);
    say sprintf('  safe-pop(a/b/c, %d) -> %s', $n, $! ?? $!.message !! $x.Str);
}

# Output:
#     popping a bare filename, or more parts than there are, produces the
#     EMPTY path — which is a very different thing from an error:
#       pop("file".IO) -> engine-dependent: an empty path, or a refusal
#     
#     Raku++ hands you "".IO, which stringifies to "" and will resolve
#     against the current directory; Rakudo refuses to build such a path
#     at all. Guard the part count yourself and neither can reach you:
#       safe-pop(a/b/c, 1) -> a/b
#       safe-pop(a/b/c, 3) -> cannot drop 3 of 3 parts
