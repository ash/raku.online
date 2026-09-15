#!/usr/bin/env rakupp
# P5hex — Where the two engines differ
# https://raku.online/modules/p5hex/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install P5hex
#     rakupp 04-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5hex;

say 'the end state of a port is core Raku, which is explicit about base:';
say '  "ff".parse-base(16)   = ', 'ff'.parse-base(16);
say '  "755".parse-base(8)   = ', '755'.parse-base(8);
say '  "101".parse-base(2)   = ', '101'.parse-base(2);
say '  :16<ff>               = ', :16<ff>;
say '';
say 'and it refuses what it cannot parse rather than answering Nil:';
my $r = try 'zz'.parse-base(16);
say '  "zz".parse-base(16)   -> ', $! ?? 'raises' !! $r.raku;
say '';
say 'that is the change the port is making: from "returns something' ;
say 'numeric whatever you give it" to "says so when the input is wrong".';

# Output:
#     the end state of a port is core Raku, which is explicit about base:
#       "ff".parse-base(16)   = 255
#       "755".parse-base(8)   = 493
#       "101".parse-base(2)   = 5
#       :16<ff>               = 255
#     
#     and it refuses what it cannot parse rather than answering Nil:
#       "zz".parse-base(16)   -> raises
#     
#     that is the change the port is making: from "returns something
#     numeric whatever you give it" to "says so when the input is wrong".
