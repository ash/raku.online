#!/usr/bin/env rakupp
# Path::Through — The four verbs
# https://raku.online/modules/path-through/#the-four-verbs
#
# Install what it needs, then run it:
#     rakupp install Path::Through
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Path::Through;

my $p = 'a/b/c/d'.IO;
say 'start          : ', $p.Str;
say 'append "e/f"   : ', append($p, 'e/f').Str;
say 'prepend "root" : ', prepend($p, 'root').Str;
say 'pop            : ', pop($p).Str;
say 'pop :2parts    : ', pop($p, parts => 2).Str;
say 'shift          : ', shift($p).Str;
say 'shift :2parts  : ', shift($p, parts => 2).Str;
say '';
say 'they return new IO::Paths; the original is untouched : ', $p.Str;

# Output:
#     start          : a/b/c/d
#     append "e/f"   : a/b/c/d/e/f
#     prepend "root" : root/a/b/c/d
#     pop            : a/b/c
#     pop :2parts    : a/b
#     shift          : b/c/d
#     shift :2parts  : c/d
#     
#     they return new IO::Paths; the original is untouched : a/b/c/d
