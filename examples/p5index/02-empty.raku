#!/usr/bin/env rakupp
# P5index — The one thing to know
# https://raku.online/modules/p5index/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install P5index
#     rakupp 02-empty.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use P5index;

my $s = 'foobar';
say 'chars           : ', $s.chars;
say 'index($s, "")   : ', index($s, '');
say 'rindex($s, "")  : ', rindex($s, '');
say '';
say 'Perl`s rindex($s, "") is length($s); this one is length($s) - 1.';
say '';
say 'the difference matters for the common "append at the last occurrence"';
say 'idiom, where an empty needle is a degenerate case you may not have';
say 'planned for:';
for 'bar', '' -> $needle {
    my $at = rindex($s, $needle);
    say sprintf('  needle %-6s -> splice at %d gives %s',
                $needle.raku, $at,
                ($s.substr(0, $at) ~ '|' ~ $s.substr($at)).raku);
}

# Output:
#     chars           : 6
#     index($s, "")   : 0
#     rindex($s, "")  : 5
#     
#     Perl`s rindex($s, "") is length($s); this one is length($s) - 1.
#     
#     the difference matters for the common "append at the last occurrence"
#     idiom, where an empty needle is a degenerate case you may not have
#     planned for:
#       needle "bar"  -> splice at 3 gives "foo|bar"
#       needle ""     -> splice at 5 gives "fooba|r"
