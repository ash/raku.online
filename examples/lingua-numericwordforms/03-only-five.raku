#!/usr/bin/env rakupp
# Lingua::NumericWordForms — The one thing to know
# https://raku.online/modules/lingua-numericwordforms/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Lingua::NumericWordForms
#     rakupp 03-only-five.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Lingua::NumericWordForms;

my @langs = <Bulgarian English Japanese Russian Koremutake
             Spanish German French Polish Korean>;
my $english = to-numeric-word-form(42, 'English');
for @langs -> $lang {
    my $out = to-numeric-word-form(42, $lang);
    say sprintf('%-11s %-18s %s', $lang, $out,
                ($out eq $english && $lang ne 'English') ?? 'silently English' !! '');
}
say to-numeric-word-form(42, 'Klingon');
say to-numeric-word-form(42, 'Klingon').defined;

# Output:
#     Bulgarian   четиридесет и две  
#     English     forty two          
#     Japanese    四十二                
#     Russian     сорок два          
#     Koremutake  la                 
#     Spanish     forty two          silently English
#     German      forty two          silently English
#     French      forty two          silently English
#     Polish      forty two          silently English
#     Korean      forty two          silently English
#     forty two
#     True
