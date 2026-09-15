#!/usr/bin/env rakupp
# TinyID — Encoding
# https://raku.online/modules/tinyid/#encoding
#
# Install what it needs, then run it:
#     rakupp install TinyID
#     rakupp 01-basics.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TinyID;

my $t = TinyID.new(key => 'cbad');
say 'key "cbad" means digits c=0 b=1 a=2 d=3';
for 0, 1, 2, 3, 4, 7, 16, 255, 1000 -> $n {
    say sprintf('  %4d -> %-6s -> %d', $n, $t.encode($n), $t.decode($t.encode($n)));
}
say '';
say 'a longer, shuffled alphabet is what you would actually use:';
my $u = TinyID.new(key => 'qWeRtYuIoPaSdFgHjKlZxCvBnM1234567890');
say '  encode(12345) = ', $u.encode(12345);
say '  decode back   = ', $u.decode($u.encode(12345));
say '';
say 'Unicode keys work too:';
my $g = TinyID.new(key => "\c[GREEK SMALL LETTER ALPHA]\c[GREEK SMALL LETTER BETA]\c[GREEK SMALL LETTER GAMMA]\c[GREEK SMALL LETTER DELTA]\c[GREEK SMALL LETTER EPSILON]");
say '  encode(31)    = ', $g.encode(31), '   decode = ', $g.decode($g.encode(31));

# Output:
#     key "cbad" means digits c=0 b=1 a=2 d=3
#          0 -> c      -> 0
#          1 -> b      -> 1
#          2 -> a      -> 2
#          3 -> d      -> 3
#          4 -> bc     -> 4
#          7 -> bd     -> 7
#         16 -> bcc    -> 16
#        255 -> dddd   -> 255
#       1000 -> ddaac  -> 1000
#     
#     a longer, shuffled alphabet is what you would actually use:
#       encode(12345) = Pl8
#       decode back   = 12345
#     
#     Unicode keys work too:
#       encode(31)    = βββ   decode = 31
