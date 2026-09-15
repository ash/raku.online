#!/usr/bin/env rakupp
# Algorithm::Soundex — The one thing to know
# https://raku.online/modules/algorithm-soundex/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Algorithm::Soundex
#     rakupp 03-short-trap.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Algorithm::Soundex;

my $sx = Algorithm::Soundex.new;

for <Lee Yee Yu Yao Aiu Iyer Smith> -> $n {
    my $c = $sx.soundex($n);
    say sprintf('%-8s => %-6s chars=%d  four characters? %s',
        $n, "'$c'", $c.chars, $c.chars == 4 ?? 'yes' !! 'NO');
}

# Output:
#     Lee      => 'L000' chars=4  four characters? yes
#     Yee      => 'Y00'  chars=3  four characters? NO
#     Yu       => 'Y00'  chars=3  four characters? NO
#     Yao      => 'Y00'  chars=3  four characters? NO
#     Aiu      => 'A000' chars=4  four characters? yes
#     Iyer     => 'I600' chars=4  four characters? yes
#     Smith    => 'S530' chars=4  four characters? yes
