#!/usr/bin/env rakupp
# Text::Sift4 — What you buy and what you pay
# https://raku.online/modules/text-sift4/#what-you-buy-and-what-you-pay
#
# Install what it needs, then run it:
#     rakupp install Text::Sift4
#     rakupp 02-speed.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Sift4;

sub lev($a, $b) {
    my @d = [0 .. $b.chars],;
    for 1 .. $a.chars -> $i {
        @d[$i][0] = $i;
        for 1 .. $b.chars -> $j {
            @d[$i][$j] = ($a.substr($i-1,1) eq $b.substr($j-1,1))
                ?? @d[$i-1][$j-1]
                !! 1 + min(@d[$i-1][$j], @d[$i][$j-1], @d[$i-1][$j-1]);
        }
    }
    @d[$a.chars][$b.chars]
}

my $a = (^300).map({ <a b c d>[($_ * 7 + 1) % 4] }).join;
my $b = (^300).map({ <a b c d>[($_ * $_ + 3) % 4] }).join;
my $true  = lev($a, $b);
my $quick = sift4($a, $b);
say "300-character strings over a 4-letter alphabet";
say "  levenshtein : $true";
say "  sift4       : $quick";
say sprintf('  sift4 reports %d%% of the true distance', (100 * $quick / $true).round);

# Output:
#     300-character strings over a 4-letter alphabet
#       levenshtein : 150
#       sift4       : 151
#       sift4 reports 101% of the true distance
