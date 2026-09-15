#!/usr/bin/env rakupp
# P5index — Using it
# https://raku.online/modules/p5index/#using-it
#
# Install what it needs, then run it:
#     rakupp install P5index
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5index;

say 'index("foobar", "bar")  = ', index('foobar', 'bar');
say 'index("foobar", "zzz")  = ', index('foobar', 'zzz'), '   <- not Nil';
say 'index("foobar", "o", 2) = ', index('foobar', 'o', 2);
say 'index("foobar", "")     = ', index('foobar', '');
say '';
say 'rindex("foobarbar", "bar")    = ', rindex('foobarbar', 'bar');
say 'rindex("foobarbar", "bar", 5) = ', rindex('foobarbar', 'bar', 5);
say 'rindex("foobar", "zzz")       = ', rindex('foobar', 'zzz');
say '';
say 'so the Perl idiom ports unchanged:';
my $s = 'foobar';
say '  if index($s, "bar") >= 0 { … } -> ', (index($s, 'bar') >= 0);
say '  if index($s, "zzz") >= 0 { … } -> ', (index($s, 'zzz') >= 0);

# Output:
#     index("foobar", "bar")  = 3
#     index("foobar", "zzz")  = -1   <- not Nil
#     index("foobar", "o", 2) = 2
#     index("foobar", "")     = 0
#     
#     rindex("foobarbar", "bar")    = 6
#     rindex("foobarbar", "bar", 5) = 3
#     rindex("foobar", "zzz")       = -1
#     
#     so the Perl idiom ports unchanged:
#       if index($s, "bar") >= 0 { … } -> True
#       if index($s, "zzz") >= 0 { … } -> False
