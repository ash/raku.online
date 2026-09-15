#!/usr/bin/env rakupp
# Path::Through — The one thing to know
# https://raku.online/modules/path-through/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Path::Through
#     rakupp 02-leading-slash.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Path::Through;

my $abs = '/a/b/c/d'.IO;
say 'start        : ', $abs.Str;
my $one = shift($abs);
say 'shift x1     : ', $one.Str, '   <- same components, now RELATIVE';
say 'shift x2     : ', shift($one).Str;
say 'shift :3parts: ', shift($abs, parts => 3).Str;
say '';
say '"/a/b/c/d".split("/") is ("", "a", "b", "c", "d"), so the first shift';
say 'consumes the empty leading element. :2parts on an absolute path drops';
say 'ONE component, :3parts drops two, and the absoluteness evaporates on';
say 'the first call.';
say '';
say 'if you mean components, check first:';
sub drop-front(IO::Path $p, Int $n) {
    my $abs = $p.is-absolute;
    my $r = shift($p, parts => $n + ($abs ?? 1 !! 0));
    $abs ?? ('/' ~ $r.Str).IO !! $r
}
say '  drop-front("/a/b/c/d", 2) = ', drop-front('/a/b/c/d'.IO, 2).Str;

# Output:
#     start        : /a/b/c/d
#     shift x1     : a/b/c/d   <- same components, now RELATIVE
#     shift x2     : b/c/d
#     shift :3parts: c/d
#     
#     "/a/b/c/d".split("/") is ("", "a", "b", "c", "d"), so the first shift
#     consumes the empty leading element. :2parts on an absolute path drops
#     ONE component, :3parts drops two, and the absoluteness evaporates on
#     the first call.
#     
#     if you mean components, check first:
#       drop-front("/a/b/c/d", 2) = /c/d
